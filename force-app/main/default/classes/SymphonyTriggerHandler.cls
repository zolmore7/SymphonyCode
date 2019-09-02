public with sharing class SymphonyTriggerHandler {
    public SymphonyTriggerHandler() {

    }


    public static void SymphonyRatingReturn(List<Sym_Rating_Return__e> symphonyRatingReturns ) {
        system.debug('###' + symphonyRatingReturns);
        //Code bulkification required
        for(Sym_Rating_Return__e srr : symphonyRatingReturns) {
            AnthemAPI.RatingResponse rr = (AnthemAPI.RatingResponse) JSON.deserialize(EncodingUtil.base64Decode(srr.payload__c).toString(), AnthemAPI.RatingResponse.class);
            //This needs to be done outside the loop
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

    public static void SymphonyIIBMessage(List<Sym_Message_Bus__e> symphonyIIBMessages) {
        system.debug('###' + symphonyIIBMessages);
        Set<Id> quoteIds = new Set<Id>();
        for(Sym_Message_Bus__e smb : symphonyIIBMessages) {
            quoteIds.add(smb.Reference_ID__c);
        }
        
        Map<Id, Sym_Case__c> caseMap = new Map<Id, Sym_Case__c>();
        List<Sym_Case__c> symCases = [SELECT Sym_Quote__c, Id, Sym_Case_Status__c FROM Sym_Case__c WHERE Sym_Quote__c IN :quoteIds];
        for(Sym_Case__c sc : symCases) {
            caseMap.put(sc.Sym_Quote__c, sc);
        }

        List<Sym_Case__c> updateSymCases = new List<Sym_Case__c>();

        for(Sym_Message_Bus__e smb : symphonyIIBMessages) {
            Sym_Case__c sc = caseMap.get(smb.Reference_ID__c);
            sc.Sym_Case_Status__c = smb.Event_Message__c;
            updateSymCases.add(sc);
            List<String> messageToPass = new List<String>();
            String theMessage = 'LG_CUSTOMER_SETUP|';
            theMessage += smb.Event_Message__c + '|';
            theMessage += smb.Reference_ID__c;
            messageToPass.add(theMessage);
            SymphonyCallBrokerPortal.sendMessageToPortal(messageToPass);        
        }

        update updateSymCases;

    }

}