package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "CropCatalog")
public class CropCatalog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CropCatalogID")
    private Integer cropCatalogId;

    @Column(name = "CropName", nullable = false, columnDefinition = "NVARCHAR(100)")
    private String cropName;

    @Column(name = "Category", nullable = false, columnDefinition = "NVARCHAR(50)")
    private String category;

    @Column(name = "MinTemp")
    private Double minTemp;

    @Column(name = "MaxTemp")
    private Double maxTemp;

    @Column(name = "MinHumid")
    private Double minHumid;

    @Column(name = "MaxHumid")
    private Double maxHumid;

    @Column(name = "ImageUrl", columnDefinition = "NVARCHAR(500)")
    private String imageUrl;

    @Column(name = "Description", columnDefinition = "NVARCHAR(500)")
    private String description;

    @Column(name = "IsSystemProvided", nullable = false)
    private Boolean isSystemProvided;

    @Column(name = "CreatedAt", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;

    public CropCatalog() {
    }

    public Integer getCropCatalogId() {
        return cropCatalogId;
    }

    public void setCropCatalogId(Integer cropCatalogId) {
        this.cropCatalogId = cropCatalogId;
    }

    public String getCropName() {
        return cropName;
    }

    public void setCropName(String cropName) {
        this.cropName = cropName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Double getMinTemp() {
        return minTemp;
    }

    public void setMinTemp(Double minTemp) {
        this.minTemp = minTemp;
    }

    public Double getMaxTemp() {
        return maxTemp;
    }

    public void setMaxTemp(Double maxTemp) {
        this.maxTemp = maxTemp;
    }

    public Double getMinHumid() {
        return minHumid;
    }

    public void setMinHumid(Double minHumid) {
        this.minHumid = minHumid;
    }

    public Double getMaxHumid() {
        return maxHumid;
    }

    public void setMaxHumid(Double maxHumid) {
        this.maxHumid = maxHumid;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getIsSystemProvided() {
        return isSystemProvided;
    }

    public void setIsSystemProvided(Boolean isSystemProvided) {
        this.isSystemProvided = isSystemProvided;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}
