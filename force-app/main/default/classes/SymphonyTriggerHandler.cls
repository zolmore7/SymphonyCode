public with sharing class SymphonyTriggerHandler {
    public SymphonyTriggerHandler() {

    }


    public static void SymphonyRatingReturn(List<Sym_Rating_Return__e> symphonyRatingReturns ) {
        system.debug('###' + symphonyRatingReturns);
        for(Sym_Rating_Return__e srr : symphonyRatingReturns) {
            AnthemAPI.RatingResponse rr = (AnthemAPI.RatingResponse) JSON.deserialize(EncodingUtil.base64Decode(srr.payload__c).toString(), AnthemAPI.RatingResponse.class);
            Quote quote = [SELECT Id FROM Quote WHERE Id = :rr.quoteHeaderID];
            quote.Symphony_Status__c = 'Plan Selection';
            update quote;
            
            Set<Id> qliIDs = new Set<Id>();

            for(AnthemAPI.RatingInfo ri : rr.rateInfo) {
                qliIDs.add(ri.quoteLineItemID);
            }
            
            Map<Id, QuoteLineItem> qliMap = new Map<Id, QuoteLineItem>([SELECT Id FROM QuoteLineItem WHERE Id IN : qliIDs]);

            for (AnthemAPI.RatingInfo ri : rr.rateInfo) {
                QuoteLineItem qli = qliMap.get(ri.quoteLineItemID);
                qli.UnitPrice = ri.single;
                qli.Sym_Rate_Single_Number__c = ri.single;
                qli.Sym_Rate_eeChildren__c = ri.eeChildren;
                qli.Sym_Rate_Family__c = ri.family;
                qli.Sym_Rate_Two_Party__c = ri.twoParty;
                qli.Sym_MonthlyPremium__c = ri.monthlyPremium;
            }
            update qliMap.values(); 
        }
    }
}