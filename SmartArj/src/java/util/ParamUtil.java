package util;

import exception.AppException;
import jakarta.servlet.http.HttpServletRequest;

public final class ParamUtil {
    private ParamUtil() {
    }

    public static String getString(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? null : value.trim();
    }

    public static String getStringOrDefault(HttpServletRequest req, String name, String defaultValue) {
        String value = getString(req, name);
        return (value == null || value.isEmpty()) ? defaultValue : value;
    }

    public static String requireString(HttpServletRequest req, String name, String message) throws AppException {
        String value = getString(req, name);
        if (value == null || value.isEmpty()) {
            throw new AppException(400, message);
        }
        return value;
    }

    public static Integer getIntOrNull(HttpServletRequest req, String name, String invalidMessage) throws AppException {
        String value = getString(req, name);
        if (value == null || value.isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            throw new AppException(400, invalidMessage, e);
        }
    }

    public static int getIntOrDefault(HttpServletRequest req, String name, int defaultValue, String invalidMessage)
            throws AppException {
        Integer value = getIntOrNull(req, name, invalidMessage);
        return value == null ? defaultValue : value;
    }

    public static int requireInt(HttpServletRequest req, String name, String missingMessage, String invalidMessage)
            throws AppException {
        String value = requireString(req, name, missingMessage);
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new AppException(400, invalidMessage, e);
        }
    }

    public static Double getDoubleOrNull(HttpServletRequest req, String name, String invalidMessage) throws AppException {
        String value = getString(req, name);
        if (value == null || value.isEmpty()) {
            return null;
        }
        try {
            return Double.valueOf(value);
        } catch (NumberFormatException e) {
            throw new AppException(400, invalidMessage, e);
        }
    }
}
