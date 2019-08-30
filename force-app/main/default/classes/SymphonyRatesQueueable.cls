// System.enqueueJob(new SymphonyRatesQueueable());

public class SymphonyRatesQueueable implements Queueable, Database.AllowsCallouts {

    private Id quoteId;

    public SymphonyRatesQueueable(Id theQuoteId) {
        this.quoteId = theQuoteId;
    }

	public void execute(QueueableContext context) {
        //Id quoteId = '0Q041000000zreE';

        APISymphonyRecPlans.getRates(quoteId);
    }

}