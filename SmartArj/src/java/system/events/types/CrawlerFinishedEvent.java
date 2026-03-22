package system.events.types;

import system.events.BaseEvent;

/**
 * Event fired when the market price crawler completes a run (scheduled or manual).
 *
 * Trigger point: CrawlerService.runCrawl() after logCrawlerRun() is called,
 * regardless of success or failure (so admin can see both outcomes).
 */
public class CrawlerFinishedEvent extends BaseEvent {

    public static final String TYPE = "CRAWLER_FINISHED";

    private final String crawlerStatus;  // SUCCESS | FAILED | NO_DATA
    private final int    itemsCrawled;
    private final int    durationMs;

    /**
     * @param crawlerStatus Result status from CrawlerService.CrawlerResult
     * @param itemsCrawled  Number of market price records crawled
     * @param durationMs    Total time taken in milliseconds
     */
    public CrawlerFinishedEvent(String crawlerStatus, int itemsCrawled, int durationMs) {
        super(null, null,
              "Crawler gi\u00e1 th\u1ecb tr\u01b0\u1eddng: " + crawlerStatus
              + " \u2014 " + itemsCrawled + " m\u1ee5c"
              + " (" + durationMs + " ms)");
        this.crawlerStatus = crawlerStatus;
        this.itemsCrawled  = itemsCrawled;
        this.durationMs    = durationMs;
    }

    @Override
    public String getType() {
        return TYPE;
    }

    public String getCrawlerStatus() { return crawlerStatus; }
    public int    getItemsCrawled()  { return itemsCrawled; }
    public int    getDurationMs()    { return durationMs; }

    public boolean isSuccess() {
        return "SUCCESS".equals(crawlerStatus);
    }
}
