package model;

import jakarta.persistence.*;

@Entity
@Table(name = "Crops")
public class Crop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CropID")
    private Integer cropId;

    @Column(name = "CropName", nullable = false, columnDefinition = "NVARCHAR(100)")
    private String cropName;

    @Column(name = "MinTemp")
    private Double minTemp;

    @Column(name = "MaxTemp")
    private Double maxTemp;

    @Column(name = "MinHumid")
    private Double minHumid;

    @Column(name = "MaxHumid")
    private Double maxHumid;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ZoneID", nullable = false)
    private Zone zone;

    public Crop() {}

    public Integer getCropId() { return cropId; }
    public void setCropId(Integer cropId) { this.cropId = cropId; }

    public String getCropName() { return cropName; }
    public void setCropName(String cropName) { this.cropName = cropName; }

    public Double getMinTemp() { return minTemp; }
    public void setMinTemp(Double minTemp) { this.minTemp = minTemp; }

    public Double getMaxTemp() { return maxTemp; }
    public void setMaxTemp(Double maxTemp) { this.maxTemp = maxTemp; }

    public Double getMinHumid() { return minHumid; }
    public void setMinHumid(Double minHumid) { this.minHumid = minHumid; }

    public Double getMaxHumid() { return maxHumid; }
    public void setMaxHumid(Double maxHumid) { this.maxHumid = maxHumid; }

    public Zone getZone() { return zone; }
    public void setZone(Zone zone) { this.zone = zone; }
}
