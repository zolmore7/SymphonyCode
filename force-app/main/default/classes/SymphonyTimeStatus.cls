global with sharing class SymphonyTimeStatus {

    public SymphonyTimeStatus() {
    }
    @AuraEnabled
    public static Sym_Case__c getCase(Id theId) {
        return [SELECT Id, Sym_Case_Status__c FROM Sym_Case__c WHERE Id = :theId];
    }
    
    @AuraEnabled
    public static String movePath(Id theId) {
        Sym_Case__c theCase = [SELECT Id, Sym_Case_Status__c FROM Sym_Case__c WHERE Id = :theId];

        Switch on theCase.Sym_Case_Status__c {
            when 'Customer setup is initiated' {
                theCase.Sym_Case_Status__c = 'Customer setup is Completed';
            }
            when 'Customer setup is Completed' {
                theCase.Sym_Case_Status__c = 'Member Enrollment Complete';
            }
            when 'Member Enrollment Complete' {
                theCase.Sym_Case_Status__c = 'Billing is activated and ID cards are available';
            }
        }

        update theCase;

        return theCase.Sym_Case_Status__c;
    }

    @AuraEnabled
    public static void callBrokerPortal(Id theId) {
        Sym_Case__c theCase = [SELECT Sym_Quote__r.Opportunity.Account.Id, Sym_Quote__r.Id, Id, Sym_Case_Status__c FROM Sym_Case__c WHERE Id = :theId];
        List<String> messageToPass = new List<String>();
        String theMessage = 'LG_CUSTOMER_SETUP|';
        theMessage += theCase.Sym_Case_Status__c + '|';
        theMessage += theCase.Sym_Quote__r.Id + '|';
        theMessage += theCase.Sym_Quote__r.Opportunity.Account.Id;
        
        messageToPass.add(theMessage);
        SymphonyCallBrokerPortal.sendMessageToPortal(messageToPass);        
    }

}