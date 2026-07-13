package dto;

import java.util.List;
import model.Zone;

public class ZoneDashboardDTO {
    private Zone zone;
    private String cityName;
    private String cropName;
    private double currentTemp;
    private double currentHumidity;
    private double currentWind;
    private double currentRain;
    private String lastUpdated; // e.g., "10 mins ago"
    private String status; // "Normal", "Warning", "Danger"
    private int alertCount;
    private List<Double> sparklineData; // Last 7 temp points

    // Getters and Setters
    public Zone getZone() {
        return zone;
    }

    public void setZone(Zone zone) {
        this.zone = zone;
    }

    public String getCityName() {
        return cityName;
    }

    public void setCityName(String cityName) {
        this.cityName = cityName;
    }

    public String getCropName() {
        return cropName;
    }

    public void setCropName(String cropName) {
        this.cropName = cropName;
    }

    public double getCurrentTemp() {
        return currentTemp;
    }

    public void setCurrentTemp(double currentTemp) {
        this.currentTemp = currentTemp;
    }

    public double getCurrentHumidity() {
        return currentHumidity;
    }

    public void setCurrentHumidity(double currentHumidity) {
        this.currentHumidity = currentHumidity;
    }

    public double getCurrentWind() {
        return currentWind;
    }

    public void setCurrentWind(double currentWind) {
        this.currentWind = currentWind;
    }

    public double getCurrentRain() {
        return currentRain;
    }

    public void setCurrentRain(double currentRain) {
        this.currentRain = currentRain;
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getAlertCount() {
        return alertCount;
    }

    public void setAlertCount(int alertCount) {
        this.alertCount = alertCount;
    }

    public List<Double> getSparklineData() {
        return sparklineData;
    }

    public void setSparklineData(List<Double> sparklineData) {
        this.sparklineData = sparklineData;
    }
}
