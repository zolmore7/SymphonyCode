public with sharing class SymphonyAddSpecialityPlans {
    public SymphonyAddSpecialityPlans() {

    }
    @InvocableMethod
    public static void addPlans(List<Id> quoteId) {
        Set<String> theSet = new Set<String>();
        theSet.add('4ST1');
        theSet.add('337XA');
        theSet.add('SUPH');

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
            if(pbe.Product2.Contract_Code__c == '337XA') {
                quoteLineItem.Sym_Orthodontic_Coverage__c = 'Not Covered';
                quoteLineItem.Sym_Rate_Single_Number__c = 35.00;
                quoteLineItem.Sym_Rate_Two_Party__c = 55.00;
                quoteLIneItem.Sym_Rate_eeChildren__c = 60.00;
                quoteLineItem.Sym_Rate_Family__c = 80.00;
                quoteLineItem.Sym_In_Network_Coinsurance__c = 100;
                quoteLineItem.Sym_In_Network_Benefit_Plan_Max_Limit__c = 1000.00;
            } else if(pbe.Product2.Contract_Code__c == '4ST1') {
                quoteLineItem.Sym_Rate_Single_Number__c = 8.00;
                quoteLineItem.Sym_Rate_Two_Party__c = 15.00;
                quoteLIneItem.Sym_Rate_eeChildren__c = 18.00;
                quoteLineItem.Sym_Rate_Family__c = 20.00;
            } else {
                quoteLineItem.Sym_Rate_Single_Number__c = 5.00;
                quoteLineItem.Sym_Rate_Two_Party__c = 8.00;
                quoteLIneItem.Sym_Rate_eeChildren__c = 8.00;
                quoteLineItem.Sym_Rate_Family__c = 12.00;
            }
            quoteLineItems.add(quoteLineItem);
        }
        insert(quoteLineItems);

    }

}