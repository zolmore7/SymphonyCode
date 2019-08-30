public with sharing class SymphonyAddSpecialityPlans {
    public SymphonyAddSpecialityPlans() {

    }
    @InvocableMethod
    public static void addPlans(List<Id> quoteId) {
        Set<String> theSet = new Set<String>();
        theSet.add('4ST1');
        theSet.add('337XA');

        //List<Product2> products = [SELECT Id, NAME FROM Product2 WHERE Contract_Code__c in :theSet];

        List<PricebookEntry> pricebookEntries = [
            SELECT
              	Product2.Contract_Code__c, Product2Id
            FROM
              	PricebookEntry
            WHERE
           	Product2.Contract_Code__c IN :theSet
        ];

        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();

        Quote quote = [SELECT Id, Opportunity.Id FROM Quote WHERE Id = :quoteId[0]];

        for(PricebookEntry pbe : pricebookEntries) {
            QuoteLineItem quoteLineItem = new QuoteLineItem();
            quoteLineItem.QuoteId = quote.Id;
            quoteLineItem.PricebookEntryId = pbe.Id;
            quoteLineItem.Product2Id = pbe.Product2Id;
            quoteLineItem.Opportunity__c = quote.OpportunityId;
            quoteLineItem.ProductStage__c = 'In Progress';
            quoteLineItem.Quantity = 1;
            quoteLineItem.UnitPrice = 950; // Should this come from PBE?
            quoteLineItems.add(quoteLineItem);
        }
        insert(quoteLineItems);
    }
}