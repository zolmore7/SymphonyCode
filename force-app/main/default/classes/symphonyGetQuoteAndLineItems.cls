public with sharing class symphonyGetQuoteAndLineItems {
    @AuraEnabled(cacheable=false)
    public static Quote getLineItems(Id recordId) {
        Quote theQuote = [SELECT Id, (SELECT Id, UnitPrice, ProductStage__c, sym_IsSold__c, Product2.Name, Product2.Sym_Coinsurance__c,Product2.Sym_Deductible__c,Product2.Sym_Primary_Care_Copay__c,Contract_Codes__c,
                                             Product2.Sym_Specialist_Copay__c,Product2.Sym_Maximum_Out_of_Pocket__c, Product2.Sym_Rx_network__c, Product2.Sym_Rx_Plan__c, Sym_MonthlyPremium__c,
                                             Product2.Sym_Coinsurance_Pharmacy__c, Product2.Sym_Preventative_Drugs_Covered__c, Product2.Sym_Temp_Rate__c FROM QuoteLineItems WHERE productLOB__c = 'Medical') 
                                             FROM Quote WHERE Id = :recordId];
        return theQuote;
    }

    @AuraEnabled
    public static String updateQuoteLineItems(Id quoteId, Id selectedLineItem) {
        String returnMessage = 'Success';
        Quote theQuote = [SELECT Id, Symphony_Status__c FROM Quote WHERE Id = :quoteId];
        //theQuote.Symphony_Status__c = 'Proposal';
        List<QuoteLineItem> theLineItems = [SELECT Id, ProductStage__c, Product2.Name FROM QuoteLineItem WHERE QuoteId = :quoteId];
        List<QuoteLineItem> modifiedLineItems = new List<QuoteLineItem>();
        for(QuoteLineItem aLineItem: theLineItems) {
            if(aLineItem.Id == selectedLineItem) {
                if(aLineItem.ProductStage__c == 'Sold') {
                    aLineItem.ProductStage__c = 'Lost';
                    returnMessage += ': ' + aLineItem.Product2.Name + ' is no longer a selected plan.';    
                } else {
                    aLineItem.ProductStage__c = 'Sold';
                    returnMessage += ': ' + aLineItem.Product2.Name + ' is now a selected plan.';
                }
                modifiedLineItems.add(aLineItem);                
            } /*else {
                aLineItem.ProductStage__c = 'Lost';
            } */
        }
        try {
            update modifiedLineItems;
            //update theQuote;
        } catch(DmlException e)  {
            returnMessage = e.getMessage();
        } 
        return returnMessage;
    }
}