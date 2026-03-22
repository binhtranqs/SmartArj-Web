package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "ZoneCrops")
public class ZoneCrop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ZoneCropID")
    private Integer zoneCropId;

    @Column(name = "ZoneID", nullable = false)
    private Integer zoneId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "CropCatalogID", nullable = false)
    private CropCatalog cropCatalog;

    @Column(name = "CreatedAt", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;

    public ZoneCrop() {
    }

    public Integer getZoneCropId() {
        return zoneCropId;
    }

    public void setZoneCropId(Integer zoneCropId) {
        this.zoneCropId = zoneCropId;
    }

    public Integer getZoneId() {
        return zoneId;
    }

    public void setZoneId(Integer zoneId) {
        this.zoneId = zoneId;
    }

    public CropCatalog getCropCatalog() {
        return cropCatalog;
    }

    public void setCropCatalog(CropCatalog cropCatalog) {
        this.cropCatalog = cropCatalog;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}
