/*
 * Symphony Proposal API
 * 
 * POST /brokerSign
 * 
 */
 @RestResource(urlMapping='/symphony/brokerSign/*')
global with sharing class APISymphonyBrokerSign {
    global class ReturnState {
        public String symphonyStatus;
        public ReturnState(String theState) {
            this.symphonyStatus = theState;
        }
    }

    @HttpPost
    global static ReturnState employerSign(SymphonyEmployerSign symphonyEmployerSign) {
        Sym_Soldcase__c soldCase = [SELECT Id FROM Sym_Soldcase__c
        WHERE Sym_Quote__c = :symphonyEmployerSign.salesForceQuoteId
        LIMIT 1];

        soldCase.Sym_Signed_Broker_FirstName__c = symphonyEmployerSign.firstName;
        soldCase.Sym_Signed_Broker_LastName__c = symphonyEmployerSign.lastName;
        soldCase.Sym_Signed_Broker_Date__c = Date.parse(symphonyEmployerSign.dateSigned);
        soldCase.Sym_Sold_Case_Status__c = 'Signed by Broker';
        update soldCase;

        return new ReturnState(soldCase.Sym_Sold_Case_Status__c);
    }

    global class SymphonyEmployerSign {
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String dateSigned {get; set;}
        public String salesForceQuoteId {get; set;}
    }
}