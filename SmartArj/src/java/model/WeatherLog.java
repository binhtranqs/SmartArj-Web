package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "WeatherLogs")
public class WeatherLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LogID")
    private Long logId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ZoneID", nullable = false)
    private Zone zone;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "RecordedAt", nullable = false)
    private Date recordedAt;

    @Column(name = "Temperature")
    private Double temperature;

    @Column(name = "Humidity")
    private Double humidity;

    @Column(name = "Rainfall")
    private Double rainfall;

    @Column(name = "Wind")
    private Double wind;

    @Column(name = "Radiation")
    private Double radiation;
  

    public WeatherLog() {}

    public Long getLogId() { return logId; }
    public Date getRecordedAt() { return recordedAt; }
    public Double getTemperature() { return temperature; }
    public Double getHumidity() { return humidity; }
    public Double getRainfall() { return rainfall; }
    public Double getWind() { return wind; }
    public Double getRadiation() { return radiation; }
    public Zone getZone() { return zone; }

    public void setLogId(Long logId) {
        this.logId = logId;
    }

    public void setZone(Zone zone) {
        this.zone = zone;
    }

    public void setRecordedAt(Date recordedAt) {
        this.recordedAt = recordedAt;
    }

    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }

    public void setHumidity(Double humidity) {
        this.humidity = humidity;
    }

    public void setRainfall(Double rainfall) {
        this.rainfall = rainfall;
    }

    public void setWind(Double wind) {
        this.wind = wind;
    }

    public void setRadiation(Double radiation) {
        this.radiation = radiation;
    }

 
    
}
