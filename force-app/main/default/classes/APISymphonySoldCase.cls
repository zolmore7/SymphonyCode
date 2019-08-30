/*
 * Symphony Proposal API
 * 
 * POST /soldcase
 * 
 */
 @RestResource(urlMapping='/symphony/soldCase/*')
global with sharing class APISymphonySoldCase {
    global class ReturnState {
        public String symphonyStatus;
        public ReturnState(String theState) {
            this.symphonyStatus = theState;
        }
    }

    @HttpPost
    global static ReturnState markSoldCase(SymphonySoldCase symphonySoldCase) {
        Quote quote = [SELECT Id, Symphony_Status__c, Opportunity.Id 
        FROM Quote 
        WHERE Id = :symphonySoldCase.salesForceQuoteId];
        
        Sym_Soldcase__c soldCase = [SELECT Id, Sym_Sold_Case_Status__c
        FROM Sym_Soldcase__c
        WHERE Sym_Quote__c = :symphonySoldCase.salesForceQuoteId
        LIMIT 1];

        Opportunity opportunity = [SELECT Id, StageName
        FROM Opportunity
        WHERE Id = :quote.Opportunity.Id];

        quote.Symphony_Status__c = 'Sold';
        update quote;

        soldCase.Sym_Sold_Case_Status__c = 'Completed';
        update soldCase;

        opportunity.stageName = 'Closed Won';
        update opportunity;

        return new ReturnState(quote.Symphony_Status__c);
    }

    global class SymphonySoldCase {
        public String salesForceQuoteId {get; set;}
        public SelectedPlans selectedPlans {get; set;}
    }

    public class SelectedPlans {
        public List<SelectedPlansList> selectedPlanList {get; set;}
    }

    public class SelectedPlansList {
        public String contractID {get; set;}
    }

}