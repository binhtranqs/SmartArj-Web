package service;

import dao.WeatherLogDAO;
import model.WeatherLog;

import java.util.List;

public class DashboardService {
    private final WeatherLogDAO dao = new WeatherLogDAO();

    public List<WeatherLog> getData(int zoneId, int limit) {
        if (limit <= 0 || limit > 500) limit = 60;
        return dao.findLatestByZone(zoneId, limit);
    }
}
