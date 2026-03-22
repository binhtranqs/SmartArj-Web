package system.events.types;

import system.events.BaseEvent;

/**
 * Event fired when a Farmer successfully creates a new product listing.
 *
 * Trigger point: FarmerService.createListing() after listingDAO.create() returns a valid ID.
 */
public class ListingCreatedEvent extends BaseEvent {

    public static final String TYPE = "LISTING_CREATED";

    private final String productName;
    private final String farmerName;

    /**
     * @param farmerId    ID of the farmer who posted the listing
     * @param listingId   ID of the newly created listing
     * @param productName Product name (e.g. "Cà phê Gia Lai")
     * @param farmerName  Full name of the farmer
     */
    public ListingCreatedEvent(Integer farmerId, Integer listingId,
                                String productName, String farmerName) {
        super(farmerId, listingId,
              "Farmer " + nvl(farmerName) + " \u0111\u0103ng s\u1ea3n ph\u1ea9m \"" + nvl(productName) + "\"");
        this.productName = productName;
        this.farmerName  = farmerName;
    }

    @Override
    public String getType() {
        return TYPE;
    }

    public String getProductName() { return productName; }
    public String getFarmerName()  { return farmerName; }

    private static String nvl(String s) {
        return s != null ? s : "?";
    }
}
