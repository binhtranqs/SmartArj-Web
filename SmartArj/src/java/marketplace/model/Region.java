package marketplace.model;

/**
 * Model đại diện cho vùng địa lý
 */
public class Region {

    private Integer regionId;
    private String regionName;
    private String province;

    public Region() {
    }

    public Region(Integer regionId, String regionName, String province) {
        this.regionId = regionId;
        this.regionName = regionName;
        this.province = province;
    }

    // Getters & Setters
    public Integer getRegionId() {
        return regionId;
    }

    public void setRegionId(Integer regionId) {
        this.regionId = regionId;
    }

    public String getRegionName() {
        return regionName;
    }

    public void setRegionName(String regionName) {
        this.regionName = regionName;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    @Override
    public String toString() {
        return regionName;
    }
}
