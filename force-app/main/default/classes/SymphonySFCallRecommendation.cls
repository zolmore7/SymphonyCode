public with sharing class SymphonySFCallRecommendation {

    //@future (callout=true)
    @InvocableMethod(label='Call Symphony RecPlans')
    public static void findPlans(List<Id> accountId) {
        //Quote quote = [SELECT Id FROM Quote WHERE Id = :quoteId];
        //Account account = [SELECT Id, Sym_recRequest__c, Sym_roster__c FROM Account Where Id = :quote.Opportunity.Account.Id];
        Account account = [SELECT Id, Sym_recRequest__c, Sym_roster__c FROM Account Where Id = :accountId[0]];
        Quote quote = [SELECT Id FROM Quote Where AccountId = :accountId[0]];

        AnthemAPI.RecommendationRequest recommendationRequest = new AnthemAPI.RecommendationRequest();
        recommendationRequest = (AnthemAPI.RecommendationRequest) JSON.deserialize(account.Sym_recRequest__c, AnthemAPI.RecommendationRequest.class);
        
        List<APISymphonyRecPlans.MemberInfo> listMI = new List<APISymphonyRecPlans.MemberInfo>();

        listMI = (List<APISymphonyRecPlans.MemberInfo>) JSON.deserialize(account.Sym_roster__c, List<APISymphonyRecPlans.MemberInfo>.class);

        APISymphonyRecPlans.findRecommendedPlans(quote.Id, recommendationRequest, listMi);
    }
}