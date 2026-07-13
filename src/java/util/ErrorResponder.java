package util;

import com.google.gson.JsonObject;
import exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public final class ErrorResponder {
    private ErrorResponder() {
    }

    public static void sendApiError(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JsonObject body = new JsonObject();
        body.addProperty("error", message);
        resp.getWriter().write(body.toString());
    }

    public static void handle(HttpServletRequest req, HttpServletResponse resp, Exception e)
            throws IOException, ServletException {
        int status = HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        String message = "Internal Server Error";

        if (e instanceof AppException) {
            AppException appException = (AppException) e;
            status = appException.getStatus();
            message = appException.getMessage();
        } else if (e.getMessage() != null && !e.getMessage().isBlank()) {
            message = e.getMessage();
        }

        if (isApiRequest(req)) {
            sendApiError(resp, status, message);
            return;
        }

        req.setAttribute("errorMessage", message);
        req.setAttribute("errorDetail", e);
        req.getRequestDispatcher("/WEB-INF/views/common/error.jsp").forward(req, resp);
    }

    public static boolean isApiRequest(HttpServletRequest req) {
        String uri = req.getRequestURI();
        String ctx = req.getContextPath();
        String path = uri.substring(ctx.length());
        return path.startsWith("/api/");
    }
}
