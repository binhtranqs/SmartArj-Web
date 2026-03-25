package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "Forecasts", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"ZoneID", "ForecastDate"})
})
public class Forecast {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ForecastID")
    private Long forecastId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ZoneID", nullable = false)
    private Zone zone;

    @Temporal(TemporalType.DATE)
    @Column(name = "ForecastDate", nullable = false)
    private Date forecastDate;

    @Column(name = "Temperature")
    private Double temperature;

    @Column(name = "Humidity")
    private Double humidity;

    @Column(name = "CityID")
    private Integer cityId;

    @Column(name = "CreatedAt")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;

    public Long getForecastId() { return forecastId; }
    public void setForecastId(Long forecastId) { this.forecastId = forecastId; }

    public Zone getZone() { return zone; }
    public void setZone(Zone zone) { this.zone = zone; }

    public Date getForecastDate() { return forecastDate; }
    public void setForecastDate(Date forecastDate) { this.forecastDate = forecastDate; }

    public Double getTemperature() { return temperature; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }

    public Double getHumidity() { return humidity; }
    public void setHumidity(Double humidity) { this.humidity = humidity; }

    public Integer getCityId() { return cityId; }
    public void setCityId(Integer cityId) { this.cityId = cityId; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
