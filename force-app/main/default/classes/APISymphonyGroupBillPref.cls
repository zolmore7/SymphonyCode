/*
 * Symphony Group Bill Pref API
 * 
 * PUT /group/billpref/{billPrefId}
 * GET /group/billpref?groupId={groupId}
 * 
 */
@RestResource(urlMapping='/symphony/group/billpref/*')
global with sharing class APISymphonyGroupBillPref {

    @HttpPut
    global static SymphonyGroupBillPref updateGroupBillPref(SymphonyGroupBillPref symphonyGroupBillPref) {
        String id = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1);

        Sym_Billing_Admin_Preferences__c billingAdminPreferences = symphonyGroupBillPref.toBillingAdminPreferences();
        billingAdminPreferences.Id = id;
        update billingAdminPreferences;

        return new SymphonyGroupBillPref(billingAdminPreferences);
    }

    @HttpGet
    global static SymphonyGroupBillPref getGroupBillPref() {
        String groupId = RestContext.request.params.get('groupId');

        SymphonyGroupBillPref symphonyGroupBillPref;

        if (String.isNotBlank(groupId)) {
			List<Sym_Billing_Admin_Preferences__c> billingAdminPreferencesList = [
                SELECT
                	Sym_Account__c, Sym_Account_Number__c, Sym_Admin_Fee_Basis__c,
                	Sym_Bank_Name__c, Sym_Bill_Delivery__c, Sym_Number_of_Bills__c,
					Sym_Payment_Account_Type__c, Sym_Payment_preference__c,
                	Sym_Routing_Number__c, Sym_Self_Billing__c, Sym_Waiting_Period__c
                FROM
                	Sym_Billing_Admin_Preferences__c
                WHERE
                	Sym_Account__c = :groupId
                LIMIT 1
            ];
            
            if (billingAdminPreferencesList.size() > 0) {
                return new SymphonyGroupBillPref(billingAdminPreferencesList[0]);
            } else {
                // No record found.
        		RestContext.response.statusCode = 404;
            }
        } else {
        	// Invalid request.
        	RestContext.response.statusCode = 400;
        }

        return symphonyGroupBillPref;
    } 


    global class SymphonyGroupBillPref {

        global String id {get; set;}
        global String groupId {get; set;}
        global String accountNumber {get; set;}
        global String adminFeeBasis {get; set;}
        global String bankName {get; set;}
        global String billDelivery {get; set;}
        global String numberOfBills {get; set;}
        global String paymentAccountType {get; set;}
        global String paymentpreference {get; set;}
        global String routingNumber {get; set;}
        global String selfBilling {get; set;}
        global String waitingPeriod {get; set;}


        global SymphonyGroupBillPref() {
        }

        global SymphonyGroupBillPref(Sym_Billing_Admin_Preferences__c billingAdminPreferences) {
            id = billingAdminPreferences.Id;
            groupId = billingAdminPreferences.Sym_Account__c;
            accountNumber = billingAdminPreferences.Sym_Account_Number__c;
            adminFeeBasis = billingAdminPreferences.Sym_Admin_Fee_Basis__c;
            bankName = billingAdminPreferences.Sym_Bank_Name__c;
            billDelivery = billingAdminPreferences.Sym_Bill_Delivery__c;
            numberOfBills = billingAdminPreferences.Sym_Number_of_Bills__c;
            paymentAccountType = billingAdminPreferences.Sym_Payment_Account_Type__c;
            paymentpreference = billingAdminPreferences.Sym_Payment_preference__c;
            routingNumber = billingAdminPreferences.Sym_Routing_Number__c;
            selfBilling = billingAdminPreferences.Sym_Self_Billing__c;
            waitingPeriod = billingAdminPreferences.Sym_Waiting_Period__c;
        }

        public Sym_Billing_Admin_Preferences__c toBillingAdminPreferences() {
            Sym_Billing_Admin_Preferences__c billingAdminPreferences = new Sym_Billing_Admin_Preferences__c();
            billingAdminPreferences.Id = id;
            billingAdminPreferences.Sym_Account__c = groupId;
            billingAdminPreferences.Sym_Account_Number__c = accountNumber;
            billingAdminPreferences.Sym_Admin_Fee_Basis__c = adminFeeBasis;
            billingAdminPreferences.Sym_Bank_Name__c = bankName;
            billingAdminPreferences.Sym_Bill_Delivery__c = billDelivery;
            billingAdminPreferences.Sym_Number_of_Bills__c = numberOfBills;
            billingAdminPreferences.Sym_Payment_Account_Type__c = paymentAccountType;
            billingAdminPreferences.Sym_Payment_preference__c = paymentpreference;
            billingAdminPreferences.Sym_Routing_Number__c = routingNumber;
            billingAdminPreferences.Sym_Self_Billing__c = selfBilling;
            billingAdminPreferences.Sym_Waiting_Period__c = waitingPeriod;

            return billingAdminPreferences;
        } 

    } 
    
}