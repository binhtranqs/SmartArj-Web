package util;

public class AgriAdviceEngine {

    public static String generateAdvice(double temp, double humidity, double rainfall) {
        StringBuilder reasoning = new StringBuilder();
        StringBuilder warnings = new StringBuilder();
        StringBuilder cropTypes = new StringBuilder();
        
        // --- 1. Rule: Humidity (Độ ẩm) ---
        if (humidity > 85) {
            reasoning.append("- Độ ẩm không khí rất cao (>85%), thích hợp cho nấm bệnh phát triển nhanh. ");
            warnings.append("- TUYỆT ĐỐI CHÚ Ý: Nguy cơ nấm bệnh (như sương mai, thán thư, mốc sương) rất cao. Cần theo dõi lá thường xuyên và đảm bảo độ thông thoáng. ");
            cropTypes.append("- Ưu tiên: Các loại rau gia vị, cây ưa ẩm nhiệt đới (rau muống, cần nước), cây trồng trong nhà màng có kiểm soát ẩm. ");
            cropTypes.append("- Hạn chế: Tránh gieo các loại họ dưa (dưa hấu, dưa lưới) ngoài trời nếu không có bạt phủ vì nấm rất dễ lan. ");
        } else if (humidity < 50) {
            reasoning.append("- Độ ẩm thấp (<50%), không khí hanh khô gây mất nước nhanh qua lá. ");
            warnings.append("- LƯU Ý: Rất dễ bị nhện đỏ, bọ trĩ tấn công. Cần tăng cường tưới nước, có thể tưới phun sương để giữ ẩm bề mặt lá. ");
            cropTypes.append("- Ưu tiên: Cây cảnh quan chịu hạn, hoặc các cây đã phát triển bộ rễ sâu. Cần che chắn gió khô. ");
        } else {
            reasoning.append("- Độ ẩm lý tưởng (50-85%), thuận lợi cho quang hợp và phát triển. ");
        }

        // --- 2. Rule: Rainfall (Lượng mưa) ---
        if (rainfall > 30) {
            reasoning.append("- Đang có mưa to (>30mm), nguy cơ gây dập nát lá mầm và xói mòn đất. ");
            warnings.append("- HÀNH ĐỘNG KHẨN CẤP: Kiểm tra ngay hệ thống mương máng, đảm bảo tiêu thoát nước ruộng. Không bón phân lúc này vì sẽ bị rửa trôi. ");
            cropTypes.append("- Gợi ý: Hạn chế gieo hạt gieo cấy mới lúc này. Đợi tạnh ráo mới xuống giống. ");
        } else if (rainfall > 10) {
            reasoning.append("- Có mưa vừa (>10mm), cung cấp đủ nước tự nhiên cho đất. ");
            warnings.append("- LƯU Ý: Có thể ngừng tưới 1-2 ngày. Theo dõi tránh đọng vũng cục bộ. ");
        } else if (rainfall > 0 && rainfall <= 10) {
            reasoning.append("- Có mưa nhỏ, giúp rửa trôi bụi bề mặt lá nhưng chưa thấm sâu vào đất. ");
        } else {
            // No rain
            if (temp > 30) {
                warnings.append("- TUYỆT ĐỐI CHÚ Ý: Trời không mưa + nắng nóng, hệ số bốc hơi mạnh. Cần thiết lập chế độ tưới thường xuyên 2 lần/ngày (sáng sớm/chiều mát). ");
            }
        }

        // --- 3. Rule: Temperature (Nhiệt độ) ---
        if (temp > 35) {
            reasoning.append("- Nắng gắt cực đoan (>35°C), cây hô hấp mạnh, dễ cháy lá và suy kiệt. ");
            warnings.append("- QUAN TRỌNG: Che lưới cắt nắng (lưới đen 50-70%) cho cây non. Tưới đẫm vào sáng sớm. Không bón đạm (N) lúc nắng nóng dễ làm sốc cây. ");
            cropTypes.append("- Ưu tiên: Các loại cây chịu nhiệt như mướp, bí xanh, dền, mồng tơi. ");
        } else if (temp >= 28 && temp <= 35) {
            reasoning.append("- Nhiệt độ cao (28-35°C), đặc trưng mùa hè/nhiệt đới. Quá trình trao đổi chất diễn ra rất nhanh. ");
            cropTypes.append("- Phù hợp: Rất tốt cho các loại rau ăn lá mùa hè (rau muống, dền, mồng tơi), họ bầu bí. ");
        } else if (temp >= 20 && temp < 28) {
            reasoning.append("- Nhiệt độ mát mẻ (20-28°C), là ngưỡng sinh trưởng tối ưu cho hầu hết các loại cây màu và cây ăn trái. ");
            cropTypes.append("- Phù hợp: Đa số các loại xà lách, cà chua, dưa leo, rau cải. ");
        } else if (temp < 20 && temp > 10) {
            reasoning.append("- Trời rát mát đến lạnh (10-20°C). Cây sinh trưởng chậm lại. ");
            cropTypes.append("- Phù hợp: Rau ôn đới, bắp cải, su hào, súp lơ, cải thảo, dâu tây. ");
            warnings.append("- LƯU Ý: Hạn chế tưới sương muộn vào chiều tối vì dễ gây nấm lạnh. ");
        } else {
            reasoning.append("- Trời quá lạnh (<10°C). Cây dễ bị sương giá. ");
            warnings.append("- CẢNH BÁO SƯƠNG GIÁ: Cần che phủ nilon, bón thêm Kali và Tro bếp để tăng sức chống chịu rét. ");
        }

        return String.format(
            "📍 Tóm tắt logic phân tích khí hậu (Dành riêng cho Bot đọc, NGHIÊM CẤM THAY ĐỔI):\n\n" +
            "1️⃣ LUẬN ĐIỂM SINH LÝ THỰC VẬT:\n%s\n\n" +
            "2️⃣ CẢNH BÁO VÀ HÀNH ĐỘNG CANH TÁC:\n%s\n\n" +
            "3️⃣ GỢI Ý CÂY TRỒNG (CHUNG):\n%s\n\n",
            reasoning.toString().trim(),
            warnings.toString().trim(),
            cropTypes.toString().trim()
        );
    }
}
