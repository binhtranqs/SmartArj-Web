package controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import dao.ChatLogDAO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ChatLog;
import model.User;
import util.JPAUtil;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * ChatBot AI Servlet
 * - Câu hỏi thời tiết/nông nghiệp → query DB thực
 * - Mọi câu hỏi khác (code, kiến thức...) → Google Gemini API
 */
@WebServlet("/api/chat")
public class ChatServlet extends HttpServlet {

    // === GROQ API (Chính) ===
    private static final String GROQ_API_KEY = "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";
    private static final String GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";
    private static final String GROQ_MODEL = "llama-3.3-70b-versatile"; // Model 70B mới nhất của Groq

    private static final String SYSTEM_CONTEXT = "Bạn đang tư vấn cho một hệ thống nông nghiệp thông minh. " +
            "Bạn là chuyên gia nông nghiệp cấp cao, đóng vai như một người bạn trợ lý thân thiết với nông dân.\n\n" +

            "=== NGUYÊN TẮC HOẠT ĐỘNG VÀ PHONG CÁCH TRẢ LỜI ===\n" +
            "1. Tự nhiên, ngắn gọn, súc tích. Dùng đại từ 'mình' và 'bạn'.\n" +
            "2. Tuyệt đối KHÔNG dùng các tiêu đề in hoa cứng nhắc.\n" +
            "3. BẮT BUỘC sử dụng các icon mở đầu dòng để đoạn hội thoại sinh động:\n" +
            "   - 🌤️: Cho câu đánh giá thời tiết hiện tại.\n" +
            "   - 🌱: Cho danh sách gợi ý cây trồng (trình bày dạng gạch đầu dòng bullet points ngắn).\n" +
            "   - ⚠️ **Lưu ý:** Cho 1 cảnh báo rủi ro thực tế (ví dụ: nấm bệnh do ẩm).\n" +
            "   - 💡 **Gợi ý:** Cho 1 lời khuyên hành động.\n" +
            "   - 📊 **Mức rủi ro:** Đánh giá mức rủi ro (Thấp/Trung bình/Cao).\n" +
            "4. Chia nội dung thành các đoạn ngắn cho dễ đọc.\n\n" +

            "=== VÍ DỤ CÂU TRẢ LỜI MẪU ===\n" +
            "🌤️ **Thời tiết hiện tại ở Đà Nẵng** khá ẩm và có mưa nhẹ, nhiệt độ khoảng 22°C.\n\n" +
            "🌱 **Bạn có thể cân nhắc trồng:**\n" +
            "* Rau muống\n" +
            "* Cải xanh\n" +
            "* Xà lách\n\n" +
            "⚠️ **Lưu ý:** Độ ẩm cao dễ phát sinh nấm bệnh, vì vậy bạn nên kiểm tra lá cây thường xuyên và chú ý tình trạng đất sau khi mưa.\n\n" +
            "💡 **Gợi ý:** Theo dõi cây sau mỗi trận mưa để phát hiện sớm dấu hiệu bất thường.\n\n" +
            "📊 **Mức rủi ro:** Trung bình.\n\n" +

            "Luôn tuân thủ ĐÚNG định dạng có chứa emoji và bullet type này.";

    // Tech context keywords → route directly to AI to avoid false-positive DB
    // matches
    private static final String[] TECH_KEYWORDS = {
            "code", "lập trình", "python", "java ", "sql", "thuật toán",
            "debug", "function", "class ", "github", "html", "css",
            "javascript", "framework", "database schema", "algorithm"
    };

    private final Gson gson = new Gson();

    private final ChatLogDAO chatLogDAO = new ChatLogDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        req.setCharacterEncoding("UTF-8");

        String message = req.getParameter("message");
        String zoneIdStr = req.getParameter("zoneId");
        String historyParam = req.getParameter("history");
        PrintWriter out = resp.getWriter();

        // --- lấy userId từ session (nullable) ---
        HttpSession session = req.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;
        Integer userId = (sessionUser != null) ? sessionUser.getUserId() : null;

        if (message == null || message.trim().isEmpty()) {
            out.print(reply("Bạn chưa nhập câu hỏi. Hãy hỏi mình bất cứ điều gì! 🌱"));
            return;
        }
        if (message.length() > 500) {
            out.print(reply("⚠️ Câu hỏi quá dài (tối đa 500 ký tự). Bạn hỏi ngắn gọn hơn được không? 😊"));
            return;
        }

        String msg = message.toLowerCase().trim();
        Integer zoneId = null;
        if (zoneIdStr != null && !zoneIdStr.isBlank()) {
            try {
                zoneId = Integer.parseInt(zoneIdStr);
            } catch (Exception ignored) {
            }
        }

        // Ưu tiên đọc vùng/thành phố từ câu hỏi của người dùng
        Integer detectedZoneId = detectZoneFromMessage(msg);
        if (detectedZoneId != null) {
            zoneId = detectedZoneId;
        }

        // Parse conversation history từ frontend
        JsonArray history = null;
        if (historyParam != null && !historyParam.isBlank()) {
            try {
                history = JsonParser.parseString(historyParam).getAsJsonArray();
            } catch (Exception ignored) {
            }
        }

        long startMs = System.currentTimeMillis();
        String intentLogged = "UNKNOWN";
        boolean wasDb = false;
        boolean aiWasCalled = false;

        try {
            // Ưu tiên: nếu hỏi về dữ liệu DB thực → query DB
            String dbAnswer = tryDbAnswer(msg, zoneId, history);
            if (dbAnswer != null) {
                wasDb = true;
                intentLogged = lastIntent; // set bởi tryDbAnswer
                out.print(reply(dbAnswer));
            } else {
                // Còn lại → Groq AI với full context hội thoại
                aiWasCalled = true;
                intentLogged = "FALLBACK_AI";
                String geminiAnswer = callGemini(message, history);
                out.print(reply(geminiAnswer));
            }
        } catch (Exception e) {
            e.printStackTrace();
            intentLogged = "ERROR";
            out.print(reply("❌ Lỗi xử lý: " + e.getMessage()));
        } finally {
            // --- Ghi ChatLog bất đồng bộ (không block response) ---
            try {
                ChatLog log = new ChatLog();
                log.setUserId(userId);
                log.setZoneId(zoneId);
                log.setMessage(message.length() > 499 ? message.substring(0, 499) : message);
                log.setIntent(intentLogged);
                log.setWasDbAnswer(wasDb);
                log.setAiCalled(aiWasCalled);
                log.setLatencyMs((int) (System.currentTimeMillis() - startMs));
                chatLogDAO.create(log);
            } catch (Exception ignored) {
                /* logging không crash chatbot */ }
        }
    }

    /** Intent của request cuối (dùng để ghi ChatLog) */
    private String lastIntent = "UNKNOWN";

    // =================================================================
    // INTENT CLASSIFIER
    // =================================================================
    private enum Intent {
        WEATHER_TODAY,
        WEATHER_FORECAST,
        GET_TEMPERATURE,
        GET_HUMIDITY,
        CROP_RECOMMENDATION,
        CROP_SUITABILITY_CHECK,
        LIST_FRUITS,
        CROP_WEATHER_IMPACT,
        FARMING_ADVICE,
        HELP,
        GREETING,
        TECH_OVERRIDE,
        ZONES,
        SUMMARY,
        EXTREMES,
        UNKNOWN
    }

    private Intent detectUserIntent(String msg) {
        if (isTechContext(msg)) return Intent.TECH_OVERRIDE;
        if (hasToken(msg, "help") || matches(msg, "trợ giúp", "hỗ trợ", "bạn làm được gì", "tính năng", "chức năng", "bạn biết gì")) return Intent.HELP;
        if (matches(msg, "xin chào", "chào bạn", "hello", "hi ", "hey")) return Intent.GREETING;

        // LIST_FRUITS
        if (matches(msg, "cây ăn quả", "trái cây", "loại trái", "cây ăn trái")) {
            return Intent.LIST_FRUITS;
        }

        // ==========================================
        // CROP_RECOMMENDATION
        // ==========================================
        boolean directCropMatch = matches(msg, 
            "trồng cây gì", "cây nào phù hợp", "trồng rau gì", "trồng loại", "nên trồng gì", "loại cây",
            "trồng được", "có thể trồng", "trồng gì", "gợi ý cây", "giống nào", "cây gì tốt", "trồng cây có phù hợp", "có nên trồng"
        );
        
        boolean hasCropObj = matches(msg, "cây", "rau", "nông sản", "giống", "hoa màu", "đặc sản", "củ", "quả", "lúa", "ngô", "khoai", "sắn");
        boolean hasAction = matches(msg, "trồng", "gieo", "xuống giống", "canh tác", "phù hợp", "nên", "gợi ý", "liệt kê", "bắt đầu");

        if (directCropMatch || (hasCropObj && hasAction)) {
             return Intent.CROP_RECOMMENDATION;
        }

        // CROP_SUITABILITY_CHECK
        if (matches(msg, "thời tiết này có hợp", "có hợp trồng", "trồng cà chua", "trồng dưa hấu được không", "sống được không", "chịu được không")) {
            return Intent.CROP_SUITABILITY_CHECK;
        }

        // CROP_WEATHER_IMPACT
        if (matches(msg, "ảnh hưởng đến", "hại cho", "bị bệnh", "hư hại", "ảnh hưởng cây không")) {
            return Intent.CROP_WEATHER_IMPACT;
        }

        // FARMING_ADVICE
        if (matches(msg, "chăm sóc", "tưới", "bón phân", "phân npk", "đạm", "lân", "kali", "sâu", "bệnh", "nấm", "rệp", "thuốc trừ sâu", "vun gốc", "cắt tỉa", "làm cỏ", "thu hoạch")) {
            return Intent.FARMING_ADVICE;
        }

        // ==========================================
        // WEATHER
        // ==========================================
        if (matches(msg, "ngày mai", "tuần này", "tuần tới", "cuối tuần", "dự báo", "ngày tới", "hôm sau", "xu hướng")) {
            return Intent.WEATHER_FORECAST;
        }

        if (matches(msg, "nhiệt độ", "bao nhiêu độ", "nóng không", "lạnh không", "độ c", "nhiệt độ hôm nay")) {
            return Intent.GET_TEMPERATURE;
        }

        if (matches(msg, "độ ẩm", "ẩm không", "bao nhiêu %")) {
            return Intent.GET_HUMIDITY;
        }

        if (matches(msg, "thời tiết hôm nay", "hôm nay", "bây giờ", "hiện tại", "mưa không", "thời tiết", "trời", "mưa", "nắng", "gió")) {
            return Intent.WEATHER_TODAY;
        }

        if (matches(msg, "cảnh báo", "alert", "nguy hiểm", "warning")) return Intent.UNKNOWN; 
        if (matches(msg, "khu vực", "zone", "vùng nào", "các zone", "danh sách zone")) return Intent.ZONES;
        if (matches(msg, "tổng quan", "thống kê tổng", "overview", "summary")) return Intent.SUMMARY;
        if (matches(msg, "kỷ lục", "cao nhất", "thấp nhất", "record")) return Intent.EXTREMES;

        return Intent.UNKNOWN;
    }

    // =================================================================
    // ROUTE: Rule-based routing với priority order, scoring, logging
    // =================================================================
    private String tryDbAnswer(String msg, Integer zoneId, JsonArray history) throws Exception {
        // === Normalize input ===
        msg = normalize(msg);

        // === Detect Intent ===
        Intent intent = detectUserIntent(msg);
        this.lastIntent = intent.name();
        System.out.println("[ChatBot] Detected Intent: " + intent);

        switch (intent) {
            case HELP:
                return getHelpMessage();

            case GREETING:
                return "Chào bạn! 👋 Mình là SmartAgri Expert AI — bạn cần tư vấn gì nào?\n" +
                        "☀️ Thời tiết thực tế theo thành phố (toàn Việt Nam)\n" +
                        "⚠️ Kiểm tra cảnh báo nông nghiệp\n" +
                        "🌱 Cây trồng phù hợp + lời khuyên chuyên sâu\n" +
                        "💧 Phân bón, tưới nước, sâu bệnh\n" +
                        "💬 Gõ 'help' để xem toàn bộ tính năng!";

            case TECH_OVERRIDE:
                return null; // Route to General AI

            case GET_TEMPERATURE:
                return handleSpecificMetric(msg, zoneId, "Temperature");

            case GET_HUMIDITY:
                return handleSpecificMetric(msg, zoneId, "Humidity");

            case LIST_FRUITS:
                return getFruitList(msg);

            case WEATHER_TODAY:
                return getSimpleWeatherAnswer(zoneId);

            case WEATHER_FORECAST:
            case CROP_WEATHER_IMPACT:
                return getWeatherAnswerWithContext(msg, zoneId);

            case CROP_RECOMMENDATION:
            case CROP_SUITABILITY_CHECK:
                return getCrops(msg, zoneId);

            case FARMING_ADVICE:
                if (matches(msg, "phân bón", "bóng phân", "đạm", "lân", "kali")) {
                    return getFertilizerAdvice(msg, zoneId);
                } else if (matches(msg, "sâu bệnh", "nấm", "rệp", "thuốc")) {
                    return getPestAdvice(msg, zoneId);
                } else if (matches(msg, "tưới", "nước")) {
                    return getIrrigationAdvice(msg, zoneId);
                }
                // Fallback catch-all for farming advice
                return getFarmingAdviceFallback(msg, zoneId);

            case ZONES:
                return getZones();

            case SUMMARY:
                return getSummary(zoneId);

            case EXTREMES:
                return getExtremes(zoneId);

            case UNKNOWN:
            default:
                return null; // Delegate to Gemini for general questions seamlessly
        }
    }

    private String getFruitList(String userQuestion) throws Exception {
        String cropSql = "SELECT CropName FROM CropCatalog WHERE Category LIKE N'%ăn quả%' OR Category LIKE N'%trái cây%' OR Category LIKE N'%Ăn quả%'";
        EntityManager em = JPAUtil.getEntityManager();
        java.util.List<String> fruits = new java.util.ArrayList<>();
        try {
            java.util.List<Object> rows = em.createNativeQuery(cropSql).getResultList();
            for (Object r : rows) {
                if(r != null) fruits.add(r.toString());
            }
        } catch (Exception ignored) {
        } finally {
            em.close();
        }

        if (fruits.isEmpty()) {
            return "Dữ liệu cho yêu cầu này hiện chưa có trong hệ thống. Chúng tôi đang cập nhật dữ liệu và tính năng này sẽ sớm được hỗ trợ trong các phiên bản tiếp theo.";
        }

        String prompt = String.format("Người dùng hỏi: \"%s\"\n\n"
            + "Hệ thống Backend CSDL đã tìm được danh sách cây ăn quả sau:\n%s\n\n"
            + "Hãy trả lời câu hỏi của người dùng chuyên nghiệp, thân thiện, tư vấn dựa HOÀN TOÀN trên danh sách này. (có thể liệt kê hoặc top các cây). "
            + "TUYỆT ĐỐI không bịa thêm cây ngoài danh sách trên.", userQuestion, String.join(", ", fruits));
        return callGemini(prompt);
    }

    private String handleSpecificMetric(String userQuestion, Integer zoneId, String metricName) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String sql = zoneId != null
                ? "SELECT TOP 1 " + metricName + ", RecordedAt FROM WeatherLogs WHERE ZoneID=" + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 " + metricName + ", RecordedAt FROM WeatherLogs ORDER BY RecordedAt DESC";
        EntityManager em = JPAUtil.getEntityManager();
        String metricLabel = metricName.equals("Temperature") ? "nhiệt độ" : "độ ẩm";
        String unit = metricName.equals("Temperature") ? "°C" : "%";
        double val = 0;
        String at = "";
        boolean found = false;
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            if (!rows.isEmpty()) {
                Object[] r = rows.get(0);
                val = r[0] != null ? ((Number) r[0]).doubleValue() : 0;
                at = r[1] != null ? r[1].toString().substring(0, 16) : "";
                found = true;
            }
        } finally {
            em.close();
        }

        if (!found) {
            return "Dữ liệu cho yêu cầu này hiện chưa có trong hệ thống. Chúng tôi đang cập nhật dữ liệu và tính năng này sẽ sớm được hỗ trợ trong các phiên bản tiếp theo.";
        }

        String prompt = String.format("Người dùng hỏi: \"%s\"\n\n"
            + "Dữ liệu từ Database hệ thống: %s tại %s lúc %s là %.1f%s.\n\n"
            + "Hãy trả lời tự nhiên, chuyên nghiệp và đúng trọng tâm vào %s dựa trên thông tin trên.",
            userQuestion, metricLabel, cityName, at, val, unit, metricLabel);
        return callGemini(prompt);
    }

    private String getFarmingAdviceFallback(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        double currTemp = 25.0, currHum = 80.0, currRain = 0.0, currWind = 0.0;
        String weatherSummary = "";

        String weatherSql = zoneId != null
                ? "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind FROM WeatherLogs WHERE ZoneID=" + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind FROM WeatherLogs ORDER BY RecordedAt DESC";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(weatherSql).getResultList();
            if (!rows.isEmpty()) {
                Object[] r = rows.get(0);
                currTemp = r[0] != null ? ((Number) r[0]).doubleValue() : 25.0;
                currHum = r[1] != null ? ((Number) r[1]).doubleValue() : 80.0;
                currRain = r[2] != null ? ((Number) r[2]).doubleValue() : 0.0;
                currWind = r[3] != null ? ((Number) r[3]).doubleValue() : 0.0;
                
                weatherSummary = String.format(
                        "Thời tiết hiện tại tại %s: %.1f°C, ẩm %.0f%%, mưa %.1fmm, gió %.1fkm/h",
                        cityName, currTemp, currHum, currRain, currWind);
            } else {
                return "Dữ liệu cho yêu cầu này hiện chưa có trong hệ thống. Chúng tôi đang cập nhật dữ liệu và tính năng này sẽ sớm được hỗ trợ trong các phiên bản tiếp theo.";
            }
        } finally {
            em.close();
        }

        String expertLogic = util.AgriAdviceEngine.generateAdvice(currTemp, currHum, currRain);

        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n"
                        + "%s\n\n"
                        + "Trọng tâm của câu hỏi này là TƯ VẤN CANH TÁC CHUNG (Farming Advice). Chuyên gia Nông Nghiệp Backend đã chạy Rule-Based Machine Learning và xuất ra kịch bản sinh lý thực vật/cảnh báo như sau:\n\n"
                        + "%s\n"
                        + "Nhiệm vụ của bạn LÀ TUYỆT ĐỐI DỰA VÀO KỊCH BẢN CHUYÊN GIA TRÊN ĐỂ TƯ VẤN, diễn giải nó bằng ngôn ngữ tự nhiên, mạch lạc, chuyên nghiệp nhất theo format 4 phần bắt buộc sau (Không được bịa thêm tư vấn lệch với chuyên gia):\n\n"
                        + "🌤️ **Tóm tắt điều kiện thời tiết:** [Tóm tắt nhiệt, ẩm, mưa].\n\n"
                        + "📌 **Tư vấn / Trả lời chính:** [Trả lời trực tiếp câu hỏi chăm sóc của người dùng dựa theo Luận điểm Sinh Lý của chuyên gia].\n\n"
                        + "⚠️ **Cảnh báo và Hành động:** [Liệt kê các cảnh báo và hướng dẫn chăm sóc từ phần Cảnh báo của chuyên gia].\n\n"
                        + "🌱 **Nhóm cây phù hợp lúc này (Mở rộng):** [Trích xuất phần Gợi Ý Cây của chuyên gia].\n",
                userQuestion, weatherSummary, expertLogic);
        return callGemini(prompt);
    }

    // =================================================================
    // INPUT HELPERS & SCORING
    // =================================================================

    /** Normalize: lowercase, trim, collapse whitespace */
    private String normalize(String msg) {
        if (msg == null)
            return "";
        return msg.toLowerCase().trim().replaceAll("\\s+", " ");
    }

    /**
     * Token-based match: single words checked with space boundaries to avoid
     * substring false-positives. Multi-word phrases use contains() as usual.
     */
    private boolean hasToken(String msg, String keyword) {
        if (keyword.contains(" "))
            return msg.contains(keyword);
        String padded = " " + msg + " ";
        return padded.contains(" " + keyword + " ");
    }

    /** Tech context check → route to AI, not DB */
    private boolean isTechContext(String msg) {
        for (String kw : TECH_KEYWORDS)
            if (msg.contains(kw))
                return true;
        return false;
    }

    /**
     * Detects if user expresses dislike/avoidance (not asking about weather).
     * e.g. "mình không thích mưa" → negative context → NOT a weather query.
     * e.g. "hôm nay mưa không?" → no negation → IS a weather query.
     */
    private boolean isNegativeWeatherContext(String msg) {
        return matches(msg, "không thích", "ghét ", "sợ ", "tránh ");
    }

    /**
     * Scoring system for weather intent detection.
     * Strong keyword = +2 (e.g. "thời tiết", "nhiệt độ")
     * Weak keyword = +1 (e.g. "mưa", "gió" — single words)
     * Context booster = +1 (e.g. "hôm nay", "ngày mai")
     * Negation guard = -3 (e.g. "không thích", "ghét")
     * Threshold: score >= 2 → confirmed weather inquiry.
     */
    private int weatherScore(String msg) {
        int score = 0;
        // Strong signals (+2)
        for (String kw : new String[] { "thời tiết", "nhiệt độ", "độ ẩm", "lượng mưa",
                "dự báo", "forecast", "temperature", "humidity", "rainfall", "weather",
                "hôm nay nóng", "hôm nay mưa", "trời đẹp" })
            if (msg.contains(kw))
                score += 2;
        // Weak signals (single words, need context to confirm intent) (+1)
        for (String kw : new String[] { "mưa", "nắng", "gió" })
            if (hasToken(msg, kw))
                score += 1;
        // Context boosters (+1)
        for (String kw : new String[] { "hôm nay", "ngày mai", "tuần này",
                "hiện tại", "bây giờ", "hôm qua", "cuối tuần" })
            if (msg.contains(kw))
                score += 1;
        // Relative date boosters (+2): "2 hôm trước", "3 ngày sau", etc.
        if (msg.matches(".*\\d+\\s*(hôm trước|ngày trước|ngày qua|hôm sau|ngày sau|ngày tới|ngày nữa).*"))
            score += 2;
        // Negation penalty (-3)
        if (isNegativeWeatherContext(msg))
            score -= 3;
        return score;
    }

    /**
     * Phân biệt câu hỏi thời tiết ĐƠN GIẢN vs CẦN PHÂN TÍCH.
     * Simple: "bao nhiêu độ?", "mưa không?", "thời tiết Hà Nội?"
     * Analysis: "ảnh hưởng cây không?", "có nên ra đồng?", "dự báo tuần tới"
     */
    private boolean isAnalysisIntent(String msg) {
        return matches(msg,
                "ảnh hưởng", "có nên", "nên không", "lời khuyên", "tư vấn",
                "phân tích", "đánh giá", "dự báo", "forecast",
                "tuần tới", "tuần này", "cuối tuần", "7 ngày", "ngày tới", "so sánh",
                "mấy ngày", "vài ngày", "những ngày",
                "ra đồng", "gieo hạt", "thu hoạch được không");
    }

    /**
     * Trả dữ liệu thời tiết thuần túy từ DB — KHÔNG gọi AI, KHÔNG gọi Forecast API.
     * Dùng cho câu hỏi đơn giản: "hôm nay bao nhiêu độ?", "thời tiết Hà Nội?"
     */
    private String getSimpleWeatherAnswer(Integer zoneId) {
        String cityName = getCityNameFromDb(zoneId);
        String sql = zoneId != null
                ? "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind, RecordedAt"
                        + " FROM WeatherLogs WHERE ZoneID=" + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind, RecordedAt"
                        + " FROM WeatherLogs ORDER BY RecordedAt DESC";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            if (rows.isEmpty())
                return "Dữ liệu cho yêu cầu này hiện chưa có trong hệ thống. Chúng tôi đang cập nhật dữ liệu và tính năng này sẽ sớm được hỗ trợ trong các phiên bản tiếp theo.";
            Object[] r = rows.get(0);
            double temp = r[0] != null ? ((Number) r[0]).doubleValue() : 0;
            double humid = r[1] != null ? ((Number) r[1]).doubleValue() : 0;
            double rain = r[2] != null ? ((Number) r[2]).doubleValue() : 0;
            double wind = r[3] != null ? ((Number) r[3]).doubleValue() : 0;
            String at = r[4] != null ? r[4].toString().substring(0, 16) : "";

            String condition = rain > 5 ? "🌧️ Mưa rào"
                    : rain > 0 ? "🌦️ Mưa nhỏ"
                            : temp > 35 ? "🔥 Nắng gắt"
                                    : temp > 30 ? "☀️ Nắng nóng"
                                            : temp > 25 ? "🌤️ Nắng đẹp" : "⛅ Mát mẻ";

            return String.format(
                    "%s **Thời tiết tại %s**\n🕐 Cập nhật: %s\n\n"
                            + "🌡️ Nhiệt độ: **%.1f°C** %s\n"
                            + "💧 Độ ẩm:    **%.0f%%**\n"
                            + "🌧️ Lượng mưa: **%.1f mm**\n"
                            + "💨 Gió:      **%.1f km/h**\n\n"
                            + "💡 Hỏi thêm 'ảnh hưởng đến cây không?' để được phân tích chuyên sâu!",
                    condition, cityName, at, temp, condition, humid, rain, wind);
        } catch (Exception e) {
            return "⚠️ Lỗi đọc dữ liệu thời tiết: " + e.getMessage();
        } finally {
            em.close();
        }
    }

    // =================================================================
    // RELATIVE DATE PARSING
    // =================================================================

    /**
     * Chuyển chuỗi số (tiếng Việt hoặc chữ số) sang int.
     */
    private int parseVietnameseNumber(String s) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ignored) {
        }
        switch (s.trim()) {
            case "một":
                return 1;
            case "hai":
                return 2;
            case "ba":
                return 3;
            case "bốn":
                return 4;
            case "năm":
                return 5;
            case "sáu":
                return 6;
            case "bảy":
                return 7;
            case "tám":
                return 8;
            case "chín":
                return 9;
            case "mười":
                return 10;
            default:
                return 1;
        }
    }

    /**
     * Phân tích ngày tương đối từ câu hỏi.
     * 0 = hôm nay / hiện tại
     * -1 = hôm qua
     * -N = N hôm/ngày trước (N > 1)
     * +1 = ngày mai / hôm sau
     * +N = N ngày sau / tới (N > 1)
     */
    private int parseDateOffset(String msg) {
        // Fixed terms
        if (msg.contains("hôm nay") || msg.contains("hiện tại") || msg.contains("bây giờ"))
            return 0;
        if (msg.contains("hôm qua") || msg.contains("ngày hôm qua"))
            return -1;
        if (msg.contains("ngày mai") || msg.contains("hôm sau") || msg.contains("ngày tới"))
            return 1;

        // "N hôm/ngày trước" (quá khứ)
        java.util.regex.Matcher mp = java.util.regex.Pattern
                .compile("(\\d+|một|hai|ba|bốn|năm|sáu|bảy|tám|chín|mười)\\s*(hôm trước|ngày trước|ngày qua)")
                .matcher(msg);
        if (mp.find())
            return -parseVietnameseNumber(mp.group(1));

        // "N ngày sau/tới/nữa" (tương lai)
        java.util.regex.Matcher mf = java.util.regex.Pattern
                .compile(
                        "(\\d+|một|hai|ba|bốn|năm|sáu|bảy|tám|chín|mười)\\s*(hôm sau|ngày sau|ngày tới|ngày nữa|ngày tiếp)")
                .matcher(msg);
        if (mf.find())
            return parseVietnameseNumber(mf.group(1));

        return 0; // Mặc định: hôm nay
    }

    /**
     * Truy vấn DB theo ngày cụ thể (offset từ hôm nay) và format câu trả lời.
     * dayOffset=0 → hôm nay, -1 → hôm qua, -2 → 2 ngày trước, v.v.
     * dayOffset > 0 → hỏi tương lai (query Forecasts table).
     */
    private String getWeatherByDateOffset(Integer zoneId, int dayOffset) {
        String cityName = getCityNameFromDb(zoneId);

        String dateLabel;
        if (dayOffset == 0)
            dateLabel = "hôm nay";
        else if (dayOffset == -1)
            dateLabel = "hôm qua";
        else if (dayOffset == 1)
            dateLabel = "ngày mai";
        else if (dayOffset < 0)
            dateLabel = Math.abs(dayOffset) + " ngày trước";
        else
            dateLabel = dayOffset + " ngày tới";

        // === 1. Xác định chính xác Local Date mong muốn (TimeZone VN) ===
        java.time.LocalDate today = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
        java.time.LocalDate targetDate = today.plusDays(dayOffset);
        String targetDateStr = targetDate.toString(); // format "YYYY-MM-DD"
        
        System.out.println("[ChatBot] === DATE RESOLUTION ===");
        System.out.println("[ChatBot] Local Today      : " + today.toString());
        System.out.println("[ChatBot] Day Offset     : " + dayOffset + " (" + dateLabel + ")");
        System.out.println("[ChatBot] Resolved Target: " + targetDateStr);

        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows;
            String sql;
            
            // Map ZoneID to CityID for broader search (AI saves forecasts to the first Zone of a City)
            String cityCond = "";
            if (zoneId != null) {
                try {
                    Object cIdObj = em.createNativeQuery("SELECT CityID FROM Zones WHERE ZoneID = " + zoneId).getSingleResult();
                    if (cIdObj != null) {
                        cityCond = "z.CityID = " + cIdObj.toString() + " AND ";
                    } else {
                        cityCond = "f.ZoneID = " + zoneId + " AND "; // fallback to ZoneID if city not found
                    }
                } catch (Exception e) {
                    cityCond = "f.ZoneID = " + zoneId + " AND ";
                }
            }
            
            double temp = 0;
            double humid = 0;
            double rain = 0;
            double wind = 0;
            String at = targetDateStr;

            // === 2. Query Tương Lai (Forecasts) vs Quá Khứ/Hiện Tại (WeatherLogs) ===
            if (dayOffset > 0) {
                // Tương lai: Bảng Forecasts CHỈ có (ForecastID, ZoneID, ForecastDate, Temperature, CreatedAt)
                sql = "SELECT TOP 1 f.Temperature, f.ForecastDate "
                    + "FROM Forecasts f "
                    + (cityCond.startsWith("z.CityID") ? "JOIN Zones z ON f.ZoneID = z.ZoneID " : "")
                    + "WHERE " + cityCond + "f.ForecastDate = '" + targetDateStr + "' "
                    + "ORDER BY f.ForecastDate DESC";
                
                System.out.println("[ChatBot] SQL Query (Forecasts) : " + sql);
                rows = em.createNativeQuery(sql).getResultList();
                
                if (rows.isEmpty()) {
                    return "⚠️ Hệ thống chưa có dữ liệu dự báo cho " + dateLabel + " (" + targetDateStr + ") tại " + cityName + ".\n"
                         + "💡 Xin vui lòng chờ hệ thống AI dự báo cập nhật.";
                }
                
                Object[] r = rows.get(0);
                temp = r[0] != null ? ((Number) r[0]).doubleValue() : 0;
                // Humidity, Rain, Wind không có trong Forecasts schema
                humid = 0; 
                rain = 0;
                wind = 0;
                
                System.out.println("[ChatBot] Fetched Row Forecast : Temp=" + temp);
                
                String condition = temp > 35  ? "🔥 Nắng gắt"
                                 : temp > 30  ? "☀️ Nắng nóng"
                                 : temp > 25  ? "🌤️ Nắng có thể rát" : "⛅ Mát mẻ";
                
                String formattedTargetDate = targetDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                
                return String.format(
                    "🔮 **Dự báo thời tiết %s tại %s**\n"
                            + "📅 Ngày dự báo: %s\n\n"
                            + "🌡️ Nhiệt độ dự báo: **%.1f°C** (%s)\n"
                            + "*(Hệ thống AI hiện thời chỉ dự báo Nhiệt độ dài ngày)*\n\n"
                            + "💡 Dựa trên hệ thống AI dự báo dài hạn, độ chính xác có thể thay đổi.",
                    dateLabel, cityName, formattedTargetDate, temp, condition);

            } else {
                // Quá khứ/Hôm nay: Bảng WeatherLogs có đầy đủ Temperature, Humidity, Rainfall, Wind
                String wCityCond = cityCond.replace("f.ZoneID", "w.ZoneID");
                sql = "SELECT TOP 1 w.Temperature, w.Humidity, w.Rainfall, w.Wind, w.RecordedAt "
                    + "FROM WeatherLogs w "
                    + (wCityCond.startsWith("z.CityID") ? "JOIN Zones z ON w.ZoneID = z.ZoneID " : "")
                    + "WHERE " + wCityCond + "CAST(w.RecordedAt AS DATE) = '" + targetDateStr + "' "
                    + "ORDER BY w.RecordedAt DESC";
                
                System.out.println("[ChatBot] SQL Query (WeatherLogs) : " + sql);
                rows = em.createNativeQuery(sql).getResultList();
                
                boolean isStale = false;
                if (rows.isEmpty()) {
                    System.out.println("[ChatBot] Fallback: Searching latest available WeatherLog");
                    String fallbackSql = "SELECT TOP 1 w.Temperature, w.Humidity, w.Rainfall, w.Wind, w.RecordedAt "
                            + "FROM WeatherLogs w "
                            + (wCityCond.startsWith("z.CityID") ? "JOIN Zones z ON w.ZoneID = z.ZoneID " : "")
                            + (wCityCond.isEmpty() ? "" : "WHERE " + wCityCond.substring(0, wCityCond.length() - 5))
                            + " ORDER BY w.RecordedAt DESC";
                    rows = em.createNativeQuery(fallbackSql).getResultList();
                    if (rows.isEmpty()) {
                         return "Dữ liệu cho yêu cầu này hiện chưa có trong hệ thống. Chúng tôi đang cập nhật dữ liệu và tính năng này sẽ sớm được hỗ trợ trong các phiên bản tiếp theo.";
                    }
                    isStale = true;
                }
                
                Object[] r = rows.get(0);
                temp  = r[0] != null ? ((Number) r[0]).doubleValue() : 0;
                humid = r[1] != null ? ((Number) r[1]).doubleValue() : 0;
                rain  = r[2] != null ? ((Number) r[2]).doubleValue() : 0;
                wind  = r[3] != null ? ((Number) r[3]).doubleValue() : 0;
                if (r[4] != null && r[4].toString().length() >= 16) {
                    at = r[4].toString().substring(0, 16);
                }
                
                System.out.println("[ChatBot] Fetched Row WeatherLog: Temp=" + temp + ", Humid=" + humid + ", Rain=" + rain);

                String atTime = "";
                String atDate = "";
                if (at.length() >= 16) {
                    atTime = at.substring(11, 16);
                    atDate = at.substring(8, 10) + "/" + at.substring(5, 7) + "/" + at.substring(0, 4);
                }

                String condition = rain > 5  ? "🌧️ Mưa rào"
                                 : rain > 0   ? "🌦️ Mưa nhỏ"
                                 : temp > 35  ? "🔥 Nắng gắt"
                                 : temp > 30  ? "☀️ Nắng nóng"
                                 : temp > 25  ? "🌤️ Nắng đẹp" : "⛅ Mát mẻ";
                
                String staleWarning = isStale ? "⚠️ *Hệ thống chưa ghi nhận dữ liệu mới trong " + dateLabel + ". Đây là bản tin thời tiết gần nhất:*\n\n" : "";
                
                return String.format(
                    staleWarning + "**Thời tiết %s tại %s**\n"
                            + "🕐 Cập nhật lúc %s, ngày %s\n\n"
                            + "🌡️ Nhiệt độ: **%.1f°C** (%s)\n"
                            + "💧 Độ ẩm:    **%.0f%%**\n"
                            + "🌧️ Lượng mưa: **%.1f mm**\n"
                            + "💨 Gió:      **%.1f km/h**\n\n"
                            + "💡 Hỏi thêm 'ảnh hưởng đến cây không?' để được phân tích chuyên sâu!",
                    dateLabel, cityName, atTime, atDate, temp, condition, humid, rain, wind);
            }
        } catch (Exception e) {
            System.out.println("[ChatBot] getWeatherByDateOffset error: " + e.getMessage());
            e.printStackTrace();
            return "⚠️ Lỗi đọc dữ liệu: " + e.getMessage();
        } finally {
            em.close();
        }
    }

    // =================================================================
    // HELP
    // =================================================================

    private String getHelpMessage() {
        return "🌱 **SmartAgri Expert AI** có thể giúp bạn:\n\n" +
                "☀️ **Thời tiết** – nhiệt độ, độ ẩm, mưa, gió tại các thành phố VN\n" +
                "🌾 **Cây trồng** – gợi ý cây phù hợp theo điều kiện thực tế\n" +
                "🐛 **Sâu bệnh** – tư vấn phòng trừ sâu hại theo mùa vụ\n" +
                "💧 **Tưới nước** – lịch tưới phù hợp theo thời tiết\n" +
                "🌿 **Phân bón** – loại phân và liều lượng theo từng giai đoạn\n" +
                "⚠️ **Cảnh báo** – kiểm tra cảnh báo nông nghiệp hiện tại\n" +
                "📊 **Thống kê** – tổng quan và kỷ lục thời tiết\n" +
                "🗺️ **Khu vực** – danh sách zone và thành phố đang theo dõi\n\n" +
                "💡 **Tip**: Hỏi theo thành phố để kết quả chính xác hơn!\n" +
                "   Ví dụ: \"Thời tiết Hà Nội hôm nay?\", \"Nên trồng gì ở Đà Lạt?\"";
    }

    // =================================================================
    // AGRICULTURE ADVICE METHODS
    // =================================================================

    /** Shared helper: lấy chuỗi mô tả thời tiết gần nhất từ DB */
    private String getWeatherContextString(Integer zoneId, String cityName) {
        String sql = zoneId != null
                ? "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs WHERE ZoneID="
                        + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs ORDER BY RecordedAt DESC";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            if (!rows.isEmpty()) {
                Object[] r = rows.get(0);
                return String.format("%.1f°C, độ ẩm %.0f%%, mưa %.1fmm, gió %.1fkm/h (ghi nhận: %s)",
                        r[0] != null ? ((Number) r[0]).doubleValue() : 0,
                        r[1] != null ? ((Number) r[1]).doubleValue() : 0,
                        r[2] != null ? ((Number) r[2]).doubleValue() : 0,
                        r[3] != null ? ((Number) r[3]).doubleValue() : 0,
                        r[4] != null ? r[4].toString().substring(0, 16) : "N/A");
            }
            return "(chưa có dữ liệu thời tiết)";
        } catch (Exception ignored) {
            return "(lỗi đọc dữ liệu thời tiết)";
        } finally {
            em.close();
        }
    }

    /** Fertilizer advice: thời tiết thực từ DB + prompt chuyên về phân bón */
    private String getFertilizerAdvice(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String weatherCtx = getWeatherContextString(zoneId, cityName);
        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n"
                        + "Thời tiết thực tế tại %s: %s\n\n"
                        + "Hãy tư vấn NGẮN GỌN về phân bón/dinh dưỡng cây trồng dựa trên điều kiện thời tiết trên. "
                        + "Nêu rõ: loại phân phù hợp, thời điểm bón, liều lượng tham khảo. "
                        + "Dùng emoji 🌿, format rõ ràng. Dùng 'mình/bạn'.",
                userQuestion, cityName, weatherCtx);
        return callGemini(prompt);
    }

    /** Pest/Disease advice: thời tiết thực từ DB + prompt chuyên về sâu bệnh */
    private String getPestAdvice(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String weatherCtx = getWeatherContextString(zoneId, cityName);
        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n"
                        + "Thời tiết thực tế tại %s: %s\n\n"
                        + "Hãy tư vấn NGẮN GỌN về phòng trừ sâu bệnh dựa trên điều kiện thời tiết trên. "
                        + "Nêu rõ: loại sâu/bệnh thường gặp trong điều kiện này, biện pháp phòng trừ, thuốc tham khảo. "
                        + "Dùng emoji ⚠️🐛. Dùng 'mình/bạn'.",
                userQuestion, cityName, weatherCtx);
        return callGemini(prompt);
    }

    /** Irrigation advice: thời tiết thực từ DB + prompt chuyên về tưới nước */
    private String getIrrigationAdvice(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String weatherCtx = getWeatherContextString(zoneId, cityName);
        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n"
                        + "Thời tiết thực tế tại %s: %s\n\n"
                        + "Hãy tư vấn NGẮN GỌN về lịch tưới nước dựa trên điều kiện thời tiết trên. "
                        + "Nêu rõ: có nên tưới không, tần suất, thời điểm tưới tốt nhất, lưu ý đặc biệt. "
                        + "Dùng emoji 💧. Dùng 'mình/bạn'.",
                userQuestion, cityName, weatherCtx);
        return callGemini(prompt);
    }

    // =================================================================
    // CITY DETECTION
    // =================================================================

    /**
     * Phát hiện tên thành phố trong câu hỏi → trả về ZoneID tương ứng trong DB.
     * Hỗ trợ cả tên có/không dấu, tên viết tắt phổ biến.
     */
    private Integer detectZoneFromMessage(String msg) {
        // [keywords...] → CityName trong DB
        Object[][] cityMap = {
                new Object[] { "HaNoi", new String[] { "hà nội", "ha noi", "hanoi", "thủ đô" } },
                new Object[] { "HoChiMinh", new String[] { "hồ chí minh", "ho chi minh", "hcm", "tp hcm",
                        "sài gòn", "saigon", "tp.hcm" } },
                new Object[] { "DaNang", new String[] { "đà nẵng", "da nang", "danang" } },
                new Object[] { "Hue", new String[] { "huế", " hue ", "thừa thiên" } },
                new Object[] { "HaiPhong", new String[] { "hải phòng", "hai phong", "haiphong" } },
                new Object[] { "CanTho", new String[] { "cần thơ", "can tho", "cantho" } },
                new Object[] { "DaLat", new String[] { "đà lạt", "da lat", "dalat", "lâm đồng" } },
                new Object[] { "NhaTrang", new String[] { "nha trang", "nhatrang", "khánh hòa" } },
                new Object[] { "DakLak", new String[] { "đắk lắk", "dak lak", "daklak",
                        "buôn ma thuột", "buon ma thuot" } },
                new Object[] { "Sapa", new String[] { "sa pa", "sapa", "lào cai", "lao cai" } },
        };

        for (Object[] entry : cityMap) {
            String cityName = (String) entry[0];
            String[] keywords = (String[]) entry[1];
            for (String kw : keywords) {
                if (msg.contains(kw)) {
                    Integer zid = getZoneIdByCity(cityName);
                    if (zid != null)
                        return zid;
                }
            }
        }
        return null;
    }

    /**
     * Lấy ZoneID đầu tiên của một city từ DB.
     * Tìm theo cả tên ASCII (key trong cityMap) VÀ tên tiếng Việt có dấu,
     * vì bảng Cities có thể lưu một trong hai dạng.
     * Mapping: ASCII key → các tên có thể có trong DB.
     */
    private Integer getZoneIdByCity(String cityNameKey) {
        // Tất cả tên có thể tồn tại trong cột Cities.CityName cho mỗi key
        java.util.Map<String,String[]> dbNameVariants = new java.util.LinkedHashMap<>();
        dbNameVariants.put("HaNoi",     new String[]{ "HaNoi", "Hà Nội", "Ha Noi", "Hanoi" });
        dbNameVariants.put("HoChiMinh", new String[]{ "HoChiMinh", "Hồ Chí Minh", "Ho Chi Minh", "TP.HCM", "TP HCM" });
        dbNameVariants.put("DaNang",    new String[]{ "DaNang", "Da Nang", "Đà Nẵng", "Danang" });
        dbNameVariants.put("Hue",       new String[]{ "Hue", "Huế", "Thua Thien" });
        dbNameVariants.put("HaiPhong",  new String[]{ "HaiPhong", "Hải Phòng", "Hai Phong", "Haiphong" });
        dbNameVariants.put("CanTho",    new String[]{ "CanTho", "Cần Thơ", "Can Tho", "Cantho" });
        dbNameVariants.put("DaLat",     new String[]{ "DaLat", "Da Lat", "Đà Lạt", "Dalat" });
        dbNameVariants.put("NhaTrang",  new String[]{ "NhaTrang", "Nha Trang", "Nhatrang" });
        dbNameVariants.put("DakLak",    new String[]{ "DakLak", "Đắk Lắk", "Dak Lak", "Daklak" });
        dbNameVariants.put("Sapa",      new String[]{ "Sapa", "Sa Pa", "Lào Cai", "Lao Cai" });

        String[] variants = dbNameVariants.getOrDefault(cityNameKey, new String[]{ cityNameKey });

        // Build: WHERE c.CityName IN ('v1','v2',...)
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < variants.length; i++) {
            if (i > 0) inClause.append(",");
            inClause.append("'").append(variants[i].replace("'", "''")).append("'");
        }
        String sql = "SELECT TOP 1 z.ZoneID FROM Zones z "
                + "JOIN Cities c ON z.CityID = c.CityID "
                + "WHERE c.CityName IN (" + inClause + ") ORDER BY z.ZoneID";

        System.out.println("[ChatBot] getZoneIdByCity key='" + cityNameKey + "' SQL: " + sql);

        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object result = em.createNativeQuery(sql).getSingleResult();
            int zid = ((Number) result).intValue();
            System.out.println("[ChatBot] getZoneIdByCity found zoneId=" + zid);
            return zid;
        } catch (NoResultException e) {
            System.out.println("[ChatBot] getZoneIdByCity NOT FOUND for key='" + cityNameKey + "'");
            return null;
        } catch (Exception e) {
            System.out.println("[ChatBot] getZoneIdByCity error: " + e.getMessage());
            return null;
        } finally {
            em.close();
        }
    }

    /**
     * Trả lời câu hỏi thời tiết bằng cách lấy context từ DB + Python API
     * rồi đưa cho Groq phân tích
     */
    private String getWeatherAnswerWithContext(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String zoneName = getZoneNameFromDb(zoneId); // giữ để dùng nội bộ nếu cần
        String location = cityName; // chỉ nêu tên thành phố, không nêu zone cụ thể
        String now = java.time.LocalDateTime.now()
                .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy"));

        // === 1. Lấy dữ liệu thời tiết từ DB (5 bản ghi gần nhất) ===
        StringBuilder dbData = new StringBuilder();
        JsonArray historyArray = new JsonArray();
        String sql = zoneId != null
                ? "SELECT TOP 5 Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs WHERE ZoneID="
                        + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 5 Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs ORDER BY RecordedAt DESC";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            int i = 0;
            for (Object[] row : rows) {
                if (i == 0)
                    dbData.append("Dữ liệu cảm biến thực tế (mới nhất trước):\n");
                String recAt = row[4] != null ? row[4].toString().substring(0, 16) : "";
                double t = row[0] != null ? ((Number) row[0]).doubleValue() : 0;
                double h = row[1] != null ? ((Number) row[1]).doubleValue() : 0;
                double r = row[2] != null ? ((Number) row[2]).doubleValue() : 0;
                double w = row[3] != null ? ((Number) row[3]).doubleValue() : 0;
                dbData.append(String.format("  [%s] Nhiệt: %.1f°C | Ẩm: %.1f%% | Mưa: %.1fmm | Gió: %.1fkm/h\n",
                        recAt, t, h, r, w));
                JsonObject logObj = new JsonObject();
                logObj.addProperty("RecordedAt", recAt.substring(0, Math.min(10, recAt.length())));
                logObj.addProperty("Temperature", t);
                logObj.addProperty("Humidity", h);
                logObj.addProperty("Rainfall", r);
                historyArray.add(logObj);
                i++;
            }
            if (i == 0) {
                return "Dữ liệu cho yêu cầu này hiện chưa có trong hệ thống. Chúng tôi đang cập nhật dữ liệu và tính năng này sẽ sớm được hỗ trợ trong các phiên bản tiếp theo.";
            }
        } catch (Exception e) {
            dbData.append("(Lỗi đọc DB: ").append(e.getMessage()).append(")\n");
        } finally {
            em.close();
        }

        // === 2. Lấy dự báo từ Python AI API ===
        String forecastData = "";
        try {
            if (historyArray.size() > 0) {
                JsonObject tempForecastResponse = requestTFTForecast("Temperature", historyArray);
                JsonObject humidForecastResponse = requestTFTForecast("Humidity", historyArray);

                if (tempForecastResponse != null && humidForecastResponse != null) {
                    JsonArray tempForecasts = tempForecastResponse.getAsJsonArray("forecast");
                    JsonArray humidForecasts = humidForecastResponse.getAsJsonArray("forecast");

                    StringBuilder fb = new StringBuilder("Dự báo AI 7 ngày tới:\n");
                    int len = Math.min(Math.min(7, tempForecasts.size()), humidForecasts.size());
                    for (int j = 0; j < len; j++) {
                        JsonObject tObj = tempForecasts.get(j).getAsJsonObject();
                        JsonObject hObj = humidForecasts.get(j).getAsJsonObject();
                        fb.append(String.format("  %s: Nhiệt %.1f°C | Ẩm %.0f%%\n",
                                tObj.get("date").getAsString(),
                                tObj.get("value").getAsDouble(),
                                hObj.get("value").getAsDouble()));
                    }
                    if (tempForecastResponse.has("insight")) {
                        fb.append("\n💡 Lời khuyên hệ thống: ")
                                .append(tempForecastResponse.get("insight").getAsString());
                    }
                    forecastData = fb.toString();
                } else {
                    forecastData = "(Python AI API dự báo không phản hồi đúng)";
                }
            } else {
                forecastData = "(Không đủ dữ liệu lịch sử để dự báo AI)";
            }
        } catch (Exception e) {
            forecastData = "(Python AI API chưa khởi động hoặc lỗi)";
        }

        // === 3. Gửi tất cả cho Groq phân tích ===
        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n" +
                        "Dữ liệu thực tế từ hệ thống SmartArj tại %s (cập nhật lúc %s):\n\n" +
                        "%s\n" +
                        "%s\n\n" +
                        "Hãy trả lời thẳng vào câu hỏi bằng tiếng Việt, rất ngắn gọn (3-5 câu), thân mật (dùng 'mình'/'bạn'). " +
                        "Trình bày như một đoạn hội thoại trôi chảy, không dùng tiêu đề in hoa cứng nhắc. " +
                        "Nếu có tư vấn nông nghiệp thì chỉ tập trung phân tích 1-3 vấn đề cốt lõi nhất, kèm 1 cảnh báo và 1 hành động.\n" +
                        "Chỉ cung cấp thêm chi tiết nếu người dùng yêu cầu.",
                userQuestion, location, now, dbData.toString(), forecastData);

        return callGemini(prompt);
    }

    // =================================================================
    // AI CALL - Groq only
    // =================================================================

    /** Không có history — dùng cho các prompt nội bộ (thời tiết, cây trồng...) */
    private String callGemini(String userMessage) throws IOException {
        return callGemini(userMessage, null);
    }

    /** Có history — dùng cho hỏi thoại thường trực tiếp từ user */
    private String callGemini(String userMessage, JsonArray history) throws IOException {
        try {
            return callGroq(userMessage, history);
        } catch (Exception e) {
            return "⏳ Mình đang bận một chút, bạn thử lại sau nhé!";
        }
    }

    /**
     * Gọi Groq API (OpenAI-compatible format)
     * history: mảng các tin nhắn trước đó [{role, content}], có thể null
     */
    private String callGroq(String userMessage, JsonArray history) throws IOException {
        JsonArray messages = new JsonArray();

        // 1. System prompt
        JsonObject systemMsg = new JsonObject();
        systemMsg.addProperty("role", "system");
        systemMsg.addProperty("content", SYSTEM_CONTEXT);
        messages.add(systemMsg);

        // 2. Lịch sử họi thoại (tối đa 10 tin gần nhất = 5 lượt)
        if (history != null) {
            int start = Math.max(0, history.size() - 10);
            for (int i = start; i < history.size(); i++) {
                try {
                    JsonObject h = history.get(i).getAsJsonObject();
                    String role = h.get("role").getAsString();
                    String content = h.get("content").getAsString();
                    if ((role.equals("user") || role.equals("assistant")) && !content.isBlank()) {
                        JsonObject hMsg = new JsonObject();
                        hMsg.addProperty("role", role);
                        hMsg.addProperty("content", content);
                        messages.add(hMsg);
                    }
                } catch (Exception ignored) {
                }
            }
        }

        // 3. Tin hiện tại
        JsonObject userMsg = new JsonObject();
        userMsg.addProperty("role", "user");
        userMsg.addProperty("content", userMessage);
        messages.add(userMsg);

        JsonObject body = new JsonObject();
        body.addProperty("model", GROQ_MODEL);
        body.add("messages", messages);
        body.addProperty("max_tokens", 1024);
        body.addProperty("temperature", 0.7);

        URL url = new URL(GROQ_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Authorization", "Bearer " + GROQ_API_KEY);
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(30000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(gson.toJson(body).getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();

        InputStream is = (status == 200) ? conn.getInputStream() : conn.getErrorStream();
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null)
                sb.append(line);
        }

        if (status == 200) {
            // Parse OpenAI-format response
            JsonObject json = JsonParser.parseString(sb.toString()).getAsJsonObject();
            return json.getAsJsonArray("choices").get(0).getAsJsonObject()
                    .getAsJsonObject("message")
                    .get("content").getAsString();
        }

        // Trả về thông tin lỗi để debug
        return "🔴 Groq lỗi " + status + ": " + sb.toString().substring(0, Math.min(200, sb.length()));
    }

    // =================================================================
    // DB QUERY METHODS
    // =================================================================
    private String getCurrentWeather(Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String zoneName = getZoneNameFromDb(zoneId);
        String location = (zoneName != null) ? zoneName + ", " + cityName : cityName;
        String now = java.time.LocalDateTime.now()
                .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy"));

        String sql = zoneId != null
                ? "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs WHERE ZoneID="
                        + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs ORDER BY RecordedAt DESC";

        double temp = 0, humid = 0, rain = 0, wind = 0;
        String recordedAt = "";
        boolean hasDbData = false;
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            if (!rows.isEmpty()) {
                Object[] row = rows.get(0);
                temp = row[0] != null ? ((Number) row[0]).doubleValue() : 0;
                humid = row[1] != null ? ((Number) row[1]).doubleValue() : 0;
                rain = row[2] != null ? ((Number) row[2]).doubleValue() : 0;
                wind = row[3] != null ? ((Number) row[3]).doubleValue() : 0;
                recordedAt = row[4] != null ? row[4].toString().substring(0, 16) : "";
                hasDbData = true;
            }
        } catch (Exception ignored) {
        } finally {
            em.close();
        }

        if (!hasDbData)
            return "⚠️ Chưa có dữ liệu thời tiết trong hệ thống cho khu vực này.";

        String condition = rain > 5 ? "🌧️ Mưa rào"
                : rain > 0 ? "🌦️ Mưa nhỏ"
                        : temp > 35 ? "🔥 Nắng gắt"
                                : temp > 30 ? "☀️ Nắng nóng"
                                        : temp > 25 ? "🌤️ Nắng đẹp" : "⛅ Mát mẻ";

        String result = String.format(
                "🌤️ Thời tiết tại %s\n🔐 Dữ liệu ghi nhận: %s\n\n" +
                        "🌡️ Nhiệt độ: %.1f°C  %s\n💧 Độ ẩm: %.1f%%\n🌧️ Lượng mưa: %.1f mm\n💨 Gió: %.1f km/h",
                location, recordedAt, temp, condition, humid, rain, wind);

        try {
            String prompt = String.format(
                    "Thời tiết hiện tại tại %s: nhiệt độ %.1f°C, độ ẩm %.1f%%, mưa %.1fmm, gió %.1fkm/h. " +
                            "Hãy đưa ra 1 lời khuyên nông nghiệp ngắn gọn (1-2 câu) phù hợp với điều kiện này.",
                    location, temp, humid, rain, wind);
            String advice = callGemini(prompt);
            if (advice != null && !advice.contains("đang bận") && !advice.contains("Lỗi"))
                result += "\n\n💡 Lời khuyên: " + advice;
        } catch (Exception ignored) {
        }
        return result;
    }

    /**
     * Lấy tên thành phố từ DB theo zoneId
     */
    private String getCityNameFromDb(Integer zoneId) {
        String sql = zoneId != null
                ? "SELECT TOP 1 c.CityName FROM Zones z JOIN Cities c ON z.CityID=c.CityID WHERE z.ZoneID=" + zoneId
                : "SELECT TOP 1 CityName FROM Cities";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object result = em.createNativeQuery(sql).getSingleResult();
            return result != null ? result.toString() : "Đà Nẵng";
        } catch (Exception ignored) {
            return "Đà Nẵng";
        } finally {
            em.close();
        }
    }

    private String getZoneNameFromDb(Integer zoneId) {
        if (zoneId == null)
            return null;
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object result = em.createNativeQuery("SELECT ZoneName FROM Zones WHERE ZoneID=" + zoneId)
                    .getSingleResult();
            return result != null ? result.toString() : null;
        } catch (Exception ignored) {
            return null;
        } finally {
            em.close();
        }
    }

    private String getWeatherStat(Integer zoneId, String col, String label, String unit) throws Exception {
        String cond = zoneId != null ? " WHERE ZoneID=" + zoneId : "";
        String sql = "SELECT AVG(" + col + "), MAX(" + col + "), MIN(" + col + ") FROM WeatherLogs" + cond;
        String sqlCurr = "SELECT TOP 1 " + col + " FROM WeatherLogs" + cond + " ORDER BY RecordedAt DESC";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object[] agg = (Object[]) em.createNativeQuery(sql).getSingleResult();
            double avg = agg[0] != null ? ((Number) agg[0]).doubleValue() : 0;
            double max = agg[1] != null ? ((Number) agg[1]).doubleValue() : 0;
            double min = agg[2] != null ? ((Number) agg[2]).doubleValue() : 0;
            Object currObj = em.createNativeQuery(sqlCurr).getSingleResult();
            double curr = currObj != null ? ((Number) currObj).doubleValue() : 0;
            return String.format(
                    "📊 Thống kê %s:\n🔵 Hiện tại: %.1f%s\n📈 Cao nhất: %.1f%s\n📉 Thấp nhất: %.1f%s\n➡️ Trung bình: %.1f%s",
                    label, curr, unit, max, unit, min, unit, avg, unit);
        } catch (Exception e) {
            return "⚠️ Không thể lấy thống kê.";
        } finally {
            em.close();
        }
    }

    private String getAlerts(Integer zoneId) throws Exception {
        String sql = "SELECT TOP 5 A.Message, A.AlertTime, Z.ZoneName FROM Alerts A JOIN Zones Z ON A.ZoneID=Z.ZoneID"
                + (zoneId != null ? " WHERE A.ZoneID=" + zoneId : "") + " ORDER BY A.AlertTime DESC";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            if (rows.isEmpty())
                return "✅ Không có cảnh báo. Tất cả khu vực đang ổn định!";
            StringBuilder sb = new StringBuilder("⚠️ Cảnh báo gần đây:\n\n");
            for (Object[] row : rows) {
                sb.append("🔴 ").append(row[2]).append("\n")
                        .append("   ").append(row[0]).append("\n")
                        .append("   🕐 ").append(row[1].toString().substring(0, 16)).append("\n\n");
            }
            return sb.toString().trim();
        } finally {
            em.close();
        }
    }

    class CropScore {
        String name;
        double minTemp, maxTemp, minHum, maxHum;
        int score;

        public CropScore(String name, double minT, double maxT, double minH, double maxH) {
            this.name = name;
            this.minTemp = minT;
            this.maxTemp = maxT;
            this.minHum = minH;
            this.maxHum = maxH;
        }

        public void calculateFitness(double wTemp, double wHum) {
            score = 0;
            // Temp criteria (priority)
            if (minTemp == 0 && maxTemp == 0) {
                score += 1; // Neutral if no data
            } else if (wTemp >= minTemp && wTemp <= maxTemp) {
                score += 3; // Perfect range
            } else if (wTemp >= minTemp - 2 && wTemp <= maxTemp + 2) {
                score += 1; // Margin of error
            } else {
                score -= 2; // Bad temp
            }

            // Hum criteria
            if (minHum == 0 && maxHum == 0) {
                score += 1; // Neutral if no data
            } else if (wHum >= minHum && wHum <= maxHum) {
                score += 2; // Perfect range
            } else if (wHum >= minHum - 10 && wHum <= maxHum + 10) {
                score += 1; // Margin of error
            } else {
                score -= 1; // Bad hum
            }
        }
    }

    private String getCrops(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);

        // === 1. Lấy thời tiết hiện tại từ DB (Lấy trước để lấy data chấm điểm) ===
        double currTemp = 25.0, currHum = 80.0, currRain = 0.0, currWind = 0.0;
        String weatherSummary = "";
        
        String weatherSql = zoneId != null
                ? "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind FROM WeatherLogs WHERE ZoneID=" + zoneId + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind FROM WeatherLogs ORDER BY RecordedAt DESC";
        EntityManager emW = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> wRows = emW.createNativeQuery(weatherSql).getResultList();
            if (!wRows.isEmpty()) {
                Object[] wr = wRows.get(0);
                currTemp = wr[0] != null ? ((Number) wr[0]).doubleValue() : 25.0;
                currHum = wr[1] != null ? ((Number) wr[1]).doubleValue() : 80.0;
                currRain = wr[2] != null ? ((Number) wr[2]).doubleValue() : 0.0;
                currWind = wr[3] != null ? ((Number) wr[3]).doubleValue() : 0.0;
                
                weatherSummary = String.format(
                        "Thời tiết hiện tại tại %s: %.1f°C, ẩm %.0f%%, mưa %.1fmm, gió %.1fkm/h",
                        cityName, currTemp, currHum, currRain, currWind);
            }
        } catch (Exception ignored) {
        } finally {
            emW.close();
        }

        // === 2. Lấy danh sách cây trồng từ DB ===
        String cropSql = "SELECT C.CropName, C.MinTemp, C.MaxTemp, C.MinHumid, C.MaxHumid "
                + "FROM CropCatalog C "
                + "JOIN ZoneCrops ZC ON C.CropCatalogID = ZC.CropCatalogID "
                + "JOIN Zones Z ON ZC.ZoneID = Z.ZoneID "
                + (zoneId != null ? " WHERE Z.ZoneID=" + zoneId : "");
        
        java.util.List<CropScore> cropList = new java.util.ArrayList<>();
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(cropSql).getResultList();
            for (Object[] row : rows) {
                String name = row[0] != null ? row[0].toString() : "Cây không tên";
                double minT = row[1] != null ? ((Number) row[1]).doubleValue() : 0;
                double maxT = row[2] != null ? ((Number) row[2]).doubleValue() : 0;
                double minH = row[3] != null ? ((Number) row[3]).doubleValue() : 0;
                double maxH = row[4] != null ? ((Number) row[4]).doubleValue() : 0;
                
                cropList.add(new CropScore(name, minT, maxT, minH, maxH));
            }
        } finally {
            em.close();
        }

        String expertLogic = util.AgriAdviceEngine.generateAdvice(currTemp, currHum, currRain);

        if (cropList.isEmpty()) {
            // NO FALLBACK DUMB MESSAGE HERE. Process Weather logical advice + Fallback to Gemini with Expert logic
            String prompt = String.format(
                    "Người dùng hỏi: \"%s\"\n\n"
                            + "%s\n\n"
                            + "Hệ thống CSDL Cây Trồng đang trống, KHÔNG CÓ DANH SÁCH CỤ THỂ. TUY NHIÊN, Chuyên gia Nông Nghiệp Backend đã chạy Rule-Based Machine Learning và xuất ra kịch bản sinh học bắt buộc như sau:\n\n"
                            + "%s\n"
                            + "Nhiệm vụ của bạn LÀ TUYỆT ĐỐI TUÂN THỦ KỊCH BẢN CHUYÊN GIA TRÊN, diễn giải nó bằng ngôn ngữ tự nhiên, mạch lạc, chuyên nghiệp nhất theo format 4 phần bắt buộc sau (Không được bịa thêm logic lệch với chuyên gia):\n\n"
                            + "🌤️ **Tóm tắt điều kiện thời tiết:** [Tóm tắt nhiệt, ẩm, mưa].\n\n"
                            + "🌱 **Gợi ý cây trồng / Nhóm cây phù hợp:** [Liệt kê top cây phù hợp dựa theo phần 3 Gợi Ý của chuyên gia].\n\n"
                            + "📌 **Lý do sinh học:** [Trình bày rõ logic từ phần 1 Luận Điểm của chuyên gia].\n\n"
                            + "⚠️ **Lưu ý canh tác:** [Liệt kê các cảnh báo từ phần 2 Cảnh Báo của chuyên gia].\n",
                    userQuestion, weatherSummary, expertLogic);
            return callGemini(prompt);
        }

        // === 3. Chấm điểm (Data-driven scoring) ===
        for (CropScore c : cropList) {
            c.calculateFitness(currTemp, currHum);
        }

        // Sắp xếp theo điểm giảm dần
        cropList.sort((c1, c2) -> Integer.compare(c2.score, c1.score));
        
        // Lấy Top 15 cây tốt nhất để AI có nhiều lựa chọn (tuỳ theo số lượng user yêu cầu)
        java.util.List<CropScore> topCrops = cropList.stream().limit(15).collect(java.util.stream.Collectors.toList());
        StringBuilder topCropsInfo = new StringBuilder();
        for(CropScore c : topCrops) {
            topCropsInfo.append(String.format("- %s (Phù hợp nhiệt: %s-%s°C, ẩm: %s-%s%%. Điểm: %d/5)\n", 
                    c.name, (int)c.minTemp, (int)c.maxTemp, (int)c.minHum, (int)c.maxHum, c.score));
        }

        // === 4. Cung cấp Data cho Groq Format câu trả lời ===
        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n"
                        + "%s\n\n"
                        + "Hệ thống Backend Dữ liệu đã tính điểm CSDL và thiết lập danh sách top cây đứng đầu về độ phù hợp với thời tiết tại %s như sau:\n%s\n"
                        + "ĐỒNG THỜI, Chuyên gia Nông Nghiệp Backend đã yêu cầu tuân thủ KHUNG LOGIC SINH HỌC sau:\n%s\n\n"
                        + "Nhiệm vụ của bạn LÀ TUYỆT ĐỐI TUÂN THỦ KHUNG LOGIC TRÊN, CHỈ ĐƯỢC CHỌN CÂY TRONG DANH SÁCH TOP DB (nếu list có). Trả lời bằng tiếng Việt chuyên nghiệp, tự nhiên, tuân thủ đúng format 4 phần bắt buộc sau (Tuyệt đối không bịa thêm logic lệch với chuyên gia):\n\n"
                        + "🌤️ **Tóm tắt điều kiện thời tiết:** [Tóm tắt nhiệt, ẩm, mưa].\n\n"
                        + "🌱 **Gợi ý cây phù hợp / độ tương thích:** [Lựa chọn số lượng cây từ danh sách DB hợp lý theo câu hỏi, phân tích độ tương thích ngắn gọn].\n\n"
                        + "📌 **Lý do (Sinh học):** [Trình bày rõ logic từ phần 1 Luận Điểm của chuyên gia kết hợp với list DB].\n\n"
                        + "⚠️ **Lưu ý canh tác:** [Liệt kê các cảnh báo từ phần 2 Cảnh Báo của chuyên gia].\n",
                userQuestion, weatherSummary, cityName, topCropsInfo.toString(), expertLogic);

        return callGemini(prompt);
    }

    /**
     * Fallback khi DB chưa có dữ liệu cây trồng:
     * Lấy thời tiết thực → Groq tư vấn loại cây phù hợp
     */
    private String getCropAdviceFromWeather(String userQuestion, Integer zoneId) throws Exception {
        String cityName = getCityNameFromDb(zoneId);
        String weatherSql = zoneId != null
                ? "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind FROM WeatherLogs WHERE ZoneID=" + zoneId
                        + " ORDER BY RecordedAt DESC"
                : "SELECT TOP 1 Temperature, Humidity, Rainfall, Wind FROM WeatherLogs ORDER BY RecordedAt DESC";
        String weatherInfo = "(chưa có dữ liệu thời tiết)";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(weatherSql).getResultList();
            if (!rows.isEmpty()) {
                Object[] r = rows.get(0);
                weatherInfo = String.format("%.1f°C, ẩm %.0f%%, mưa %.1fmm, gió %.1fkm/h",
                        r[0] != null ? ((Number) r[0]).doubleValue() : 0,
                        r[1] != null ? ((Number) r[1]).doubleValue() : 0,
                        r[2] != null ? ((Number) r[2]).doubleValue() : 0,
                        r[3] != null ? ((Number) r[3]).doubleValue() : 0);
            }
        } catch (Exception ignored) {
        } finally {
            em.close();
        }

        String prompt = String.format(
                "Người dùng hỏi: \"%s\"\n\n"
                        + "Thời tiết thực tế tại %s: %s\n\n"
                        + "Hệ thống chưa có danh sách cụ thể, hãy tự đánh giá thời tiết trên và gợi ý 1-3 loại cây/nông sản phù hợp nhất để trồng tại khu vực này.\n"
                        + "BẮT BUỘC định dạng y chang form mẫu sau:\n"
                        + "🌤️ [Đoạn tóm tắt thời tiết]\n\n"
                        + "🌱 **Bạn có thể cân nhắc trồng:**\n* [Cây 1]\n* [Cây 2]\n\n"
                        + "⚠️ **Lưu ý:** [Cảnh báo sinh học].\n\n"
                        + "💡 **Gợi ý:** [Khuyên hành động].\n\n"
                        + "📊 **Mức rủi ro:** [Thấp/Trung/Cao].\n",
                userQuestion, cityName, weatherInfo);
        return callGemini(prompt);
    }

    private String getZones() throws Exception {
        String sql = "SELECT Z.ZoneID, Z.ZoneName, C.CityName, "
                + "(SELECT COUNT(*) FROM Crops Cr WHERE Cr.ZoneID = Z.ZoneID) AS CropCount "
                + "FROM Zones Z LEFT JOIN Cities C ON Z.CityID = C.CityID ORDER BY C.CityName";
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            if (rows.isEmpty())
                return "⚠️ Chưa có khu vực nào.";
            StringBuilder sb = new StringBuilder();
            String lastCity = "";
            for (Object[] row : rows) {
                String city = row[2] != null ? row[2].toString() : "";
                if (!city.equals(lastCity)) {
                    sb.append("\n🏙️ ").append(city).append(":\n");
                    lastCity = city;
                }
                int crops = row[3] != null ? ((Number) row[3]).intValue() : 0;
                sb.append("  📍 ").append(row[1])
                        .append(crops > 0 ? " (" + crops + " loại cây)" : " (chưa có cây trồng)").append("\n");
            }
            return "🗺️ Hệ thống hiện có **" + rows.size() + " khu vực** trải dài nhiều thành phố:\n"
                    + sb.toString().trim();
        } finally {
            em.close();
        }
    }

    private String getSummary(Integer zoneId) throws Exception {
        String sql = "SELECT COUNT(*), AVG(Temperature), AVG(Humidity) FROM WeatherLogs"
                + (zoneId != null ? " WHERE ZoneID=" + zoneId : "");
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object[] row = (Object[]) em.createNativeQuery(sql).getSingleResult();
            return String.format(
                    "📊 Tổng quan:\n📁 Bản ghi thời tiết: %d\n🌡️ Nhiệt độ TB: %.1f°C\n💧 Độ ẩm TB: %.1f%%",
                    row[0] != null ? ((Number) row[0]).intValue() : 0,
                    row[1] != null ? ((Number) row[1]).doubleValue() : 0,
                    row[2] != null ? ((Number) row[2]).doubleValue() : 0);
        } catch (Exception e) {
            return "⚠️ Không có dữ liệu.";
        } finally {
            em.close();
        }
    }

    private String getExtremes(Integer zoneId) throws Exception {
        String sql = "SELECT MAX(Temperature), MIN(Temperature), MAX(Rainfall) FROM WeatherLogs"
                + (zoneId != null ? " WHERE ZoneID=" + zoneId : "");
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object[] row = (Object[]) em.createNativeQuery(sql).getSingleResult();
            return String.format(
                    "📈 Kỷ lục:\n🔥 Nhiệt độ cao nhất: %.1f°C\n🧣 Thấp nhất: %.1f°C\n🌧️ Mưa nhiều nhất: %.1f mm",
                    row[0] != null ? ((Number) row[0]).doubleValue() : 0,
                    row[1] != null ? ((Number) row[1]).doubleValue() : 0,
                    row[2] != null ? ((Number) row[2]).doubleValue() : 0);
        } catch (Exception e) {
            return "⚠️ Không có dữ liệu.";
        } finally {
            em.close();
        }
    }

    // =================================================================
    // HELPERS
    // =================================================================
    private boolean matches(String msg, String... keywords) {
        for (String kw : keywords)
            if (msg.contains(kw))
                return true;
        return false;
    }

    private String reply(String text) {
        JsonObject obj = new JsonObject();
        obj.addProperty("status", "success");
        obj.addProperty("reply", text);
        return gson.toJson(obj);
    }

    private JsonObject requestTFTForecast(String targetName, JsonArray historyArray) {
        String aiServiceUrl = "http://localhost:8001/predict";

        JsonObject requestBodyObj = new JsonObject();
        requestBodyObj.addProperty("target", targetName);
        requestBodyObj.add("history", historyArray);
        requestBodyObj.add("thresholds", new JsonObject());

        String requestBody = gson.toJson(requestBodyObj);

        try {
            URL url = new URL(aiServiceUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setRequestProperty("Accept", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(15000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int status = conn.getResponseCode();
            if (status == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
                StringBuilder responseStr = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    responseStr.append(line);
                }
                reader.close();

                return gson.fromJson(responseStr.toString(), JsonObject.class);
            } else {
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
