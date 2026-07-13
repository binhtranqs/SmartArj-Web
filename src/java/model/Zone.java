package model;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "Zones")
public class Zone {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ZoneID")
    private Integer zoneId;

    // ✅ DB là CityID (int), KHÔNG phải CityName
    @Column(name = "CityID", nullable = false)
    private Integer cityId;

    // ✅ DB: OwnerID (FK -> Users.UserID)
    @Column(name = "OwnerID", nullable = false)
    private Integer ownerId;

    @Column(name = "ZoneName", columnDefinition = "NVARCHAR(100)")
    private String zoneName;

    @Column(name = "Latitude")
    private Double latitude;

    @Column(name = "Longitude")
    private Double longitude;

    @Column(name = "Description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @OneToMany(mappedBy = "zone", fetch = FetchType.LAZY)
    private transient List<Crop> crops;

    public Zone() {}

    public Integer getZoneId() { return zoneId; }
    public void setZoneId(Integer zoneId) { this.zoneId = zoneId; }

    public Integer getCityId() { return cityId; }
    public void setCityId(Integer cityId) { this.cityId = cityId; }

    public Integer getOwnerId() { return ownerId; }
    public void setOwnerId(Integer ownerId) { this.ownerId = ownerId; }

    public String getZoneName() { return zoneName; }
    public void setZoneName(String zoneName) { this.zoneName = zoneName; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
