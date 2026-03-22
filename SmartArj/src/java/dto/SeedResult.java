package dto;

/**
 * Kết quả trả về từ WeatherSeedService.seedRange() và seedIfNeeded().
 */
public class SeedResult {

    private int insertedCount;
    private int skippedExistingCount;
    private int failedCount;
    private int requestedDays;
    private String message;

    public SeedResult() {
    }

    public SeedResult(int requestedDays, int insertedCount, int skippedExistingCount, int failedCount, String message) {
        this.requestedDays = requestedDays;
        this.insertedCount = insertedCount;
        this.skippedExistingCount = skippedExistingCount;
        this.failedCount = failedCount;
        this.message = message;
    }

    // Getters / Setters
    public int getInsertedCount() {
        return insertedCount;
    }

    public void setInsertedCount(int insertedCount) {
        this.insertedCount = insertedCount;
    }

    public int getSkippedExistingCount() {
        return skippedExistingCount;
    }

    public void setSkippedExistingCount(int skippedExistingCount) {
        this.skippedExistingCount = skippedExistingCount;
    }

    public int getFailedCount() {
        return failedCount;
    }

    public void setFailedCount(int failedCount) {
        this.failedCount = failedCount;
    }

    public int getRequestedDays() {
        return requestedDays;
    }

    public void setRequestedDays(int requestedDays) {
        this.requestedDays = requestedDays;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "SeedResult{inserted=" + insertedCount
                + ", skipped=" + skippedExistingCount
                + ", failed=" + failedCount
                + ", requested=" + requestedDays + "}";
    }
}
