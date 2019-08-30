public with sharing class SymphonyCostShareGetQuoteLineItems {
    public SymphonyCostShareGetQuoteLineItems() {

    }

    @AuraEnabled(cacheable=false)
    public static Quote getLineItems(Id recordId) {
        Quote theQuote = [SELECT Id, (SELECT Id, Sym_IS_Vision__c, Sym_IS_Dental__c, Sym_IS_SuppHealth__c, productLOB__c, UnitPrice, ProductStage__c, sym_IsSold__c, Product2.Name, Product2.Sym_Coinsurance__c,Product2.Sym_Deductible__c,Product2.Sym_Primary_Care_Copay__c,Contract_Codes__c,
                                             Product2.Sym_Specialist_Copay__c,Product2.Sym_Maximum_Out_of_Pocket__c, Product2.Sym_Rx_network__c, Product2.Sym_Rx_Plan__c,
                                             Product2.Sym_Coinsurance_Pharmacy__c, Product2.Sym_Preventative_Drugs_Covered__c, Product2.Sym_Temp_Rate__c FROM QuoteLineItems WHERE productLOB__c = 'Supp Health' OR productLOB__c = 'Dental' OR productLOB__c = 'Vision') 
                                             FROM Quote WHERE Id = :recordId];
        return theQuote;
    }

}