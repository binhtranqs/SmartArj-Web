package model;

import jakarta.persistence.*;

/**
 * Entity ánh xạ tới bảng Cities.
 * Dùng để load danh sách thành phố cho dropdown trong form Zone.
 */
@Entity
@Table(name = "Cities")
public class City {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CityID")
    private Integer cityId;

    @Column(name = "CityName", nullable = false, columnDefinition = "NVARCHAR(100)")
    private String cityName;

    @Column(name = "Region", columnDefinition = "NVARCHAR(100)")
    private String region;

    @Column(name = "Latitude")
    private Double latitude;

    @Column(name = "Longitude")
    private Double longitude;

    public City() {}

    public Integer getCityId()            { return cityId; }
    public void setCityId(Integer cityId) { this.cityId = cityId; }

    public String getCityName()              { return cityName; }
    public void setCityName(String cityName) { this.cityName = cityName; }

    public String getRegion()            { return region; }
    public void setRegion(String region) { this.region = region; }

    public Double getLatitude()              { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude()               { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    @Override
    public String toString() {
        return "City{id=" + cityId + ", name=" + cityName + ", region=" + region + "}";
    }
}
