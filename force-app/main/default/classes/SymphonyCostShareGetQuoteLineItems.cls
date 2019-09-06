public with sharing class SymphonyCostShareGetQuoteLineItems {
    public SymphonyCostShareGetQuoteLineItems() {

    }

    @AuraEnabled(cacheable=false)
    public static Quote getLineItems(Id recordId) {
        Quote theQuote = [SELECT Id, (SELECT Id, Sym_In_Network_Coinsurance__c, Sym_Orthodontic_Coverage__c, Sym_Rate_Single_Number__c, Sym_Rate_eeChildren__c, Sym_Rate_Family__c, Sym_Rate_Two_Party__c, Sym_IS_Vision__c, Sym_IS_Dental__c, Sym_IS_SuppHealth__c, productLOB__c, UnitPrice, ProductStage__c, sym_IsSold__c, Product2.Name, Product2.Sym_Coinsurance__c,Product2.Sym_Deductible__c,Product2.Sym_Primary_Care_Copay__c,Contract_Codes__c,
                                             Sym_Exam_Frequency__c, Sym_Lens_Copay__c, Sym_Frame_Benefit__c, Sym_Contact_Lens_Benefit__c, Sym_In_Network_Benefit_Plan_Max_Limit__c, Sym_MonthlyPremium__c, Sym_Hospital_Admission__c, Sym_Emergency_Room__c, Sym_Diagnostic_Exam__c, Product2.Sym_Specialist_Copay__c,Product2.Sym_Maximum_Out_of_Pocket__c, Product2.Description, Product2.Sym_Rx_network__c, Product2.Sym_Rx_Plan__c,
                                             Product2.Sym_Coinsurance_Pharmacy__c, Product2.Sym_Preventative_Drugs_Covered__c, Product2.Sym_Temp_Rate__c FROM QuoteLineItems WHERE productLOB__c = 'Supp Health' OR productLOB__c = 'Dental' OR productLOB__c = 'Vision') 
                                             FROM Quote WHERE Id = :recordId ORDER BY Id];
        return theQuote;
    }

}