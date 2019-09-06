public with sharing class SymphonyCaseUtil {

    @InvocableMethod(label='Create Case')
    public static void createCase(List<Id> quoteIds) {
        for (Id quoteId : quoteIds) {
            createCase(quoteId);
        }
    }

    public static void createCase(Id quoteId) {
        Quote quote = [
            SELECT
            	Account.Name, Account.BillingCity, Account.BillingState, Account.BillingStreet, Account.BillingPostalCode,
            	ContactId, Contact.FirstName, Contact.LastName, Contact.Phone, Account.County__c, Sym_Effective_Date__c,
            	OpportunityId, Opportunity.StageName, Sym_Employer_Main_Contact_Email__c, Symphony_Status__c,
				Account.SicDesc
            FROM
            	Quote
            WHERE
            	Id = :quoteId
        ];
        
        Sym_Billing_Admin_Preferences__c billingAdminPreferences = [
            SELECT
            	Sym_Account_Number__c, Sym_Admin_Fee_Basis__c, Sym_Bank_Name__c, Sym_Bill_Delivery__c,
            	Sym_Routing_Number__c, Sym_Self_Billing__c, Sym_Waiting_Period__c, Sym_Number_of_Bills__c,
	            Sym_Payment_Account_Type__c, Sym_Payment_preference__c
			FROM
            	Sym_Billing_Admin_Preferences__c
            WHERE
            	Sym_Account__c = :quote.AccountId
        ];
        
        Sym_Census__c census = [
            SELECT
            	Sym_Active_Member_Count__c, Sym_Average_age_of_Employees__c, Sym_Contract_type__c, Sym_Current_As_Of__c,
				Sym_Date_of_Birth__c, Sym_Employee_Active__c, Sym_Employee_Age_Ranges__c, Sym_employeeChildrenPMPM__c,
				Sym_Employee_Cobra__c, sym_employee_retiree__c, Sym_employeeSpousePMPM__c, Sym_Employee_total__c,
				Sym_Employee_with_dependents__c, Sym_FamilyPMPM__c, Sym_Gender__c, Sym_indvidualPMPM__c,
				sym_inputTier__c, Sym_Number_below_20__c, Sym_Number_Between_21_30__c, Sym_Number_between_31_40__c,
				Sym_Number_between_41_50__c, Sym_Number_between_51_60__c, Sym_Number_Employee_Spouse__c,
				SYm_Number_of_family_plans__c, Sym_Number_of_Female__c, Sym_Number_of_individual_plans__c,
				Sym_Number_of_Male__c, Sym_Number_of_Plans__c, Sym_Number_over_60__c, sym_outputTier__c,
				Sym_ParticipationRate__c, Sym_Total_Dependents_Org__c, Sym_Total_Subscriber_Count_Org__c,
            	Sym_State__c
			FROM
            	Sym_Census__c
            WHERE
            	Sym_Account__c = :quote.AccountId
        ];

        Sym_Fine_Tune_Recommendation__c fineTuneRecommendation = [
            SELECT
            	Sym_Data_sets_visible_to_client__c, Sym_Family_In_Network_Deductible_Max__c, Sym_Family_In_Network_Deductible_Min__c,
				Sym_Fam_Out_Network_Deductible_Max__c, Sym_Fam_Out_Network_Deductible_Min__c, Sym_Family_Max_OoP_in_ntwrk_max__c,
				Sym_Family_Max_Oo_in_ntwrk_min__c, Sym_Family_Max_OoP_ot_ntwrk_max__c, Sym_Family_Max_OoP_ot_ntwrk_min__c,
				Sym_HMO_Medical_Plan__c, Sym_HSA_Medical_Plan__c, Sym_In_Network_Coinsurance_Maximum__c, Sym_In_Network_Coinsurance_Minimum__c,
				Sym_Indivdl_Ddtbl_InNet_Max__c, Sym_Indvdl_In_Ntwk_Deduct_Min__c, Sym_Indvl_Out_Network_Ddct_Max__c, Sym_Invdl_Out_Ntwk_Dtbl_Min__c,
	            Sym_Indvdl_Max_OoP_in_ntwrk_max__c, Sym_Individual_Max_OoP_in_ntwrk__c, Sym_Indvdl_Max_OoP_ot_ntwrk_max__c,
				Sym_Indvdl_Max_OoP_ot_ntwrk_min__c, Sym_Out_Network_Coinsurance_Maximum__c, Sym_Out_Network_Coinsurance_Minimum__c,
	            Sym_Pharmacy_Tier_1_coinsur_max__c, Sym_Pharmacy_Tier_1_coinsur_min__c, Sym_Pharmacy_Tier_1_copay_max2__c,
				Sym_Pharmacy_Tier_1_copay_min__c, Sym_Pharmacy_Tier_2_coinsur_max__c, Sym_Pharmacy_Tier_2_coinsur_min__c, Sym_Pharmacy_Tier_2_copay_max__c,
				Sym_Pharmacy_Tier_2_copay_min__c, Sym_Pharmacy_Tier_3_coinsur_max__c, Sym_Pharmacy_Tier_3_coinsur_min__c, Sym_Pharmacy_Tier_3_copay_max__c,
				Sym_Pharmacy_Tier_3_copay_min__c, Sym_Pharmacy_Tier_4_coinsur_max__c, Sym_Pharmacy_Tier_4_Coinsur_min__c, Sym_Pharmacy_Tier_4_copay_max__c,
				Sym_Pharmacy_Tier_4_copay_min__c, Sym_POS_Medical_Plan__c, Sym_PPO_Medical_Plan__c, Sym_Prescription_Coinsurance_Maximum__c,
				Sym_Prescription_Coinsurance_Minimum__c, Sym_Prescription_Copay_maximum__c, Sym_Prescription_Copay_minimum__c, 
            	Sym_Prioritize_Medical_Plans__c, Sym_Recommendation_Strength__c
			FROM
            	Sym_Fine_Tune_Recommendation__c
            WHERE
            	Sym_Account__c = :quote.AccountId
        ];

        Sym_Soldcase__c soldCase = [
            SELECT
            	Sym_Signed_Broker_FirstName__c, Sym_Signed_Broker_LastName__c, Sym_Sold_Case_Status__c
			FROM
            	Sym_Soldcase__c
            WHERE
            	Sym_Quote__c = :quoteId LIMIT 1
        ];

        Sym_Summary_of_Benefits__c summaryOfBenefits = [
            SELECT
            	Sym_Avg_Prem_PMPM__c,
            	Sym_Target_Deductible_Family_INN__c, Sym_Target_Deductible_Family_ONN__c, Sym_Target_Deductible_Family_OON__c, Sym_Target_Deductible_Individual_INN__c,
            	Sym_Target_Deductible_Individual_OON__c, Sym_Target_INN_Coinsurance__c, Sym_Target_OON_Coinsurance__c, Sym_Target_OOP_Max_Family_INN__c,
				Sym_Target_OOP_Max_Family_OON__c, Sym_Target_OOP_Max_Individual_INN__c, Sym_Target_OOP_Max_Individual_OON__c, Sym_Target_Rx_Tier_Four_Coinsurance__c,
				Sym_Target_Rx_Tier_Four_Copay__c, Sym_Target_Rx_Tier_One_Coinsurance__c, Sym_Target_Rx_Tier_One_Copay__c, Sym_Target_Rx_Tier_Three_Coinsurance__c,
				Sym_Target_Rx_Tier_Three_Copay__c, Sym_Target_Rx_Tier_Two_Coinsurance__c, Sym_Target_Rx_Tier_Two_Copay__c, Sym_Total_Average_Premium__c,
                Sym_Total_Deductible_Family_INN__c, Sym_Total_Deductible_Family_OON__c, Sym_Total_OOP_Max_Individual_in_Network__c, Sym_Current_Coinsurance_INN__c,
				Sym_Current_Coinsurance_OON__c, Sym_Current_Family_Deductible_In_Network__c, Sym_Current_Family_Deductible_OON__c, Sym_Current_Individual_Deduct_In_Network__c,
				Sym_Current_Individual_Deductible_OON__c, Sym_Current_OOP_max_Family_INN__c, Sym_Current_OOP_max_Family_OON__c, Sym_Current_OOP_max_Individual_INN__c,
				Sym_Current_OOP_max_Individual_OON__c, Sym_Current_premium_PMPM_Family_INN__c, Sym_Current_premium_PMPM_Family_OON__c, Sym_Current_premium_PMPM_Individual_IN__c,
				Sym_Current_premium_PMPM_Individual_OON__c, Sym_Current_Rx_Tier_Four_Coinsurance__c, Sym_Current_Rx_Tier_Four_Copay__c, Sym_Current_Rx_Tier_One_Coinsurance__c,
				Sym_Current_Rx_Tier_One_Copay__c, Sym_Current_Rx_Tier_Three_Coinsurance__c, Sym_Current_Rx_Tier_Three_Copay__c, Sym_Current_Rx_Tier_Two_Coinsurance__c,
				Sym_Current_Rx_Tier_Two_Copay__c
			FROM
            	Sym_Summary_of_Benefits__c
            WHERE
            	Sym_Account__c = :quote.AccountId
        ];
        
        Sym_Case__c symCase = new Sym_Case__c();
        symCase.Sym_account_id__c = quote.AccountId;
        symCase.Sym_account_name__c = quote.Account.Name;
        symCase.Sym_Account_Number__c = billingAdminPreferences.Sym_Account_Number__c;
        symCase.Sym_Active_Member_Count__c = census.Sym_Active_Member_Count__c;
        symCase.Sym_Admin_Fee_Basis__c = billingAdminPreferences.Sym_Admin_Fee_Basis__c;
        symCase.Sym_Data_sets_visible_to_client__c = fineTuneRecommendation.Sym_Data_sets_visible_to_client__c;
        symCase.Sym_Average_age_of_Employees__c = census.Sym_Average_age_of_Employees__c;
        symCase.Sym_Avg_Prem_PMPM__c = summaryOfBenefits.Sym_Avg_Prem_PMPM__c;
        symCase.Sym_Bank_Name__c = billingAdminPreferences.Sym_Bank_Name__c;
        symCase.Sym_Bill_Delivery__c = billingAdminPreferences.Sym_Bill_Delivery__c;
        symCase.Sym_Billing_Admin_Preferences_ID__c = billingAdminPreferences.Id;
        symCase.Sym_billing_city__c = quote.Account.BillingCity;
        //symCase.sym_billing_state__c = quote.Account.BillingState;
        symCase.sym_billing_state__c = census.Sym_State__c;
        symCase.Sym_billing_street__c = quote.Account.BillingStreet;
        symCase.sym_billing_postal_code__c = quote.Account.BillingPostalCode;
        symCase.Sym_Broker_Contact_ID__c = quote.ContactId;
        symCase.Sym_Broker_First_Name__c = soldCase.Sym_Signed_Broker_FirstName__c;
        //symCase.Sym_Broker_Last_Name__c = soldCase.Sym_Signed_Broker_LastName__c;
        symCase.Sym_Broker_Last_Name__c = quote.Contact.LastName;
        symCase.Sym_Brokerage_Account_ID__c = quote.AccountId;
        symCase.Sym_Brokerage_Account_Name__c = quote.Account.Name;
        //symCase.Sym_Case_Status__c = soldCase.Sym_Sold_Case_Status__c;
        symCase.Sym_Case_Status__c = 'Customer setup is initiated';
        symCase.Sym_Census_ID__c = census.Id;
        symCase.Sym_Contract_Type__c = census.Sym_Contract_type__c;
        symCase.sym_county__c = quote.Account.County__c;
        symCase.Sym_Current_As_Of__c = census.Sym_Current_As_Of__c;
        symCase.Sym_Current_Coinsurance_INN__c = summaryOfBenefits.Sym_Current_Coinsurance_INN__c;
        symCase.Sym_Current_Coinsurance_OON__c = summaryOfBenefits.Sym_Current_Coinsurance_OON__c;
        symCase.Sym_Current_Family_Deductible_In_Network__c = summaryOfBenefits.Sym_Current_Family_Deductible_In_Network__c;
        symCase.Sym_Current_Family_Deductible_OON__c = summaryOfBenefits.Sym_Current_Family_Deductible_OON__c;
        symCase.Sym_Current_Individual_Deduct_In_Network__c = summaryOfBenefits.Sym_Current_Individual_Deduct_In_Network__c;
        symCase.Sym_Current_Individual_Deductible_OON__c = summaryOfBenefits.Sym_Current_Individual_Deductible_OON__c;
        symCase.Sym_Current_OOP_max_Family_INN__c = summaryOfBenefits.Sym_Current_OOP_max_Family_INN__c;
        symCase.Sym_Current_OOP_max_Family_OON__c = summaryOfBenefits.Sym_Current_OOP_max_Family_OON__c;
        symCase.Sym_Current_OOP_max_Individual_INN__c = summaryOfBenefits.Sym_Current_OOP_max_Individual_INN__c;
        symCase.Sym_Current_OOP_max_Individual_OON__c = summaryOfBenefits.Sym_Current_OOP_max_Individual_OON__c;
        symCase.Sym_Current_premium_PMPM_Family_INN__c = summaryOfBenefits.Sym_Current_premium_PMPM_Family_INN__c;
        symCase.Sym_Current_premium_PMPM_Family_OON__c = summaryOfBenefits.Sym_Current_premium_PMPM_Family_OON__c;
        symCase.Sym_Current_premium_PMPM_Individual_IN__c = summaryOfBenefits.Sym_Current_premium_PMPM_Individual_IN__c;
        symCase.Sym_Current_premium_PMPM_Individual_OON__c = summaryOfBenefits.Sym_Current_premium_PMPM_Individual_OON__c;
        symCase.Sym_Current_Rx_Tier_Four_Coinsurance__c = summaryOfBenefits.Sym_Current_Rx_Tier_Four_Coinsurance__c;
        symCase.Sym_Current_Rx_Tier_Four_Copay__c = summaryOfBenefits.Sym_Current_Rx_Tier_Four_Copay__c;
        symCase.Sym_Current_Rx_Tier_One_Coinsurance__c = summaryOfBenefits.Sym_Current_Rx_Tier_One_Coinsurance__c;
        symCase.Sym_Current_Rx_Tier_One_Copay__c = summaryOfBenefits.Sym_Current_Rx_Tier_One_Copay__c;
        symCase.Sym_Current_Rx_Tier_Three_Coinsurance__c = summaryOfBenefits.Sym_Current_Rx_Tier_Three_Coinsurance__c;
        symCase.Sym_Current_Rx_Tier_Three_Copay__c = summaryOfBenefits.Sym_Current_Rx_Tier_Three_Copay__c;
        symCase.Sym_Current_Rx_Tier_Two_Coinsurance__c = summaryOfBenefits.Sym_Current_Rx_Tier_Two_Coinsurance__c;
        symCase.Sym_Current_Rx_Tier_Two_Copay__c = summaryOfBenefits.Sym_Current_Rx_Tier_Two_Copay__c;
        symCase.Sym_Date_of_Birth__c = census.Sym_Date_of_Birth__c;
        symCase.Sym_Effective_Date__c = quote.Sym_Effective_Date__c;
        symCase.Sym_Employee_Active__c = census.Sym_Employee_Active__c;
        symCase.Sym_Employee_Age_Ranges__c = census.Sym_Employee_Age_Ranges__c;
        symCase.Sym_Employee_Children_PMPM__c = census.Sym_employeeChildrenPMPM__c;
        symCase.Sym_Employee_Cobra__c = census.Sym_Employee_Cobra__c;
        symCase.sym_employee_retiree__c = census.sym_employee_retiree__c;
        symCase.Employee_Spouse_PMPM__c = census.Sym_employeeSpousePMPM__c;
        symCase.Sym_Employee_total__c = census.Sym_Employee_total__c;
        symCase.Sym_Employee_with_dependents__c = census.Sym_Employee_with_dependents__c;
        symCase.Sym_Family_In_Network_Deductible_Max__c = fineTuneRecommendation.Sym_Family_In_Network_Deductible_Max__c;
        symCase.Sym_Family_In_Network_Deductible_Min__c = fineTuneRecommendation.Sym_Family_In_Network_Deductible_Min__c;
        symCase.Sym_Fam_Out_Network_Deductible_Max__c = fineTuneRecommendation.Sym_Fam_Out_Network_Deductible_Max__c;
        symCase.Sym_Fam_Out_Network_Deductible_Min__c = fineTuneRecommendation.Sym_Fam_Out_Network_Deductible_Min__c;
        symCase.Sym_Family_Max_OoP_in_ntwrk_max__c = fineTuneRecommendation.Sym_Family_Max_OoP_in_ntwrk_max__c;
        symCase.Sym_Family_Max_Oo_in_ntwrk_min__c = fineTuneRecommendation.Sym_Family_Max_Oo_in_ntwrk_min__c;
        symCase.Sym_Family_Max_OoP_ot_ntwrk_max__c = fineTuneRecommendation.Sym_Family_Max_OoP_ot_ntwrk_max__c;
        symCase.Sym_Family_Max_OoP_ot_ntwrk_min__c = fineTuneRecommendation.Sym_Family_Max_OoP_ot_ntwrk_min__c;
        symCase.Sym_Family_PMPM__c = census.Sym_FamilyPMPM__c;
        symCase.Sym_Gender__c = census.Sym_Gender__c;
        symCase.Sym_HMO_Medical_Plan__c = fineTuneRecommendation.Sym_HMO_Medical_Plan__c;
        symCase.Sym_HSA_Medical_Plan__c = fineTuneRecommendation.Sym_HSA_Medical_Plan__c;
        symCase.Sym_In_Network_Coinsurance_Maximum__c = fineTuneRecommendation.Sym_In_Network_Coinsurance_Maximum__c;
        symCase.Sym_In_Network_Coinsurance_Minimum__c = fineTuneRecommendation.Sym_In_Network_Coinsurance_Minimum__c;
        symCase.Sym_Indivdl_Ddtbl_InNet_Max__c = fineTuneRecommendation.Sym_Indivdl_Ddtbl_InNet_Max__c;
        symCase.Sym_Indvdl_In_Ntwk_Deduct_Min__c = fineTuneRecommendation.Sym_Indvdl_In_Ntwk_Deduct_Min__c;
        symCase.Sym_Indvl_Out_Network_Ddct_Max__c = fineTuneRecommendation.Sym_Indvl_Out_Network_Ddct_Max__c;
        symCase.Sym_Invdl_Out_Ntwk_Dtbl_Min__c = fineTuneRecommendation.Sym_Invdl_Out_Ntwk_Dtbl_Min__c;
        symCase.Sym_Individual_PMPM__c = census.Sym_indvidualPMPM__c;
        symCase.Sym_Indvdl_Max_OoP_in_ntwrk_max__c = fineTuneRecommendation.Sym_Indvdl_Max_OoP_in_ntwrk_max__c;
        symCase.Sym_Individual_Max_OoP_in_ntwrk__c = fineTuneRecommendation.Sym_Individual_Max_OoP_in_ntwrk__c;
        symCase.Sym_Indvdl_Max_OoP_ot_ntwrk_max__c = fineTuneRecommendation.Sym_Indvdl_Max_OoP_ot_ntwrk_max__c;
        symCase.Sym_Indvdl_Max_OoP_ot_ntwrk_min__c = fineTuneRecommendation.Sym_Indvdl_Max_OoP_ot_ntwrk_min__c;
        symCase.sym_inputTier__c = census.sym_inputTier__c;
        symCase.Sym_Number_below_20__c = census.Sym_Number_below_20__c;
        symCase.Sym_Number_Between_21_30__c = census.Sym_Number_Between_21_30__c;
        symCase.Sym_Number_between_31_40__c = census.Sym_Number_between_31_40__c;
        symCase.Sym_Number_between_41_50__c = census.Sym_Number_between_41_50__c;
        symCase.Sym_Number_between_51_60__c = census.Sym_Number_between_51_60__c;
        symCase.Sym_Number_Employee_Spouse__c = census.Sym_Number_Employee_Spouse__c;
        symCase.Sym_Number_of_Bills__c = billingAdminPreferences.Sym_Number_of_Bills__c;
        //symCase.sym_number_of_employees__c = String.valueOf(census.Sym_Employee_total__c);
        symCase.sym_number_of_employees__c = String.valueOf(census.Sym_Active_Member_Count__c);
        symCase.SYm_Number_of_family_plans__c = census.SYm_Number_of_family_plans__c;
        symCase.Sym_Number_of_Female__c = census.Sym_Number_of_Female__c;
        symCase.Sym_Number_of_individual_plans__c = census.Sym_Number_of_individual_plans__c;
        symCase.Sym_Number_of_Male__c = census.Sym_Number_of_Male__c;
        symCase.Sym_Number_of_Plans__c = census.Sym_Number_of_Plans__c;
        symCase.Sym_Number_over_60__c = census.Sym_Number_over_60__c;
        symCase.sym_opportunity_id__c = quote.OpportunityId;
        symCase.sym_opportunity_stage__c = quote.Opportunity.StageName;
        symCase.Sym_Out_Network_Coinsurance_Maximum__c = fineTuneRecommendation.Sym_Out_Network_Coinsurance_Maximum__c;
        symCase.Sym_Out_Network_Coinsurance_Minimum__c = fineTuneRecommendation.Sym_Out_Network_Coinsurance_Minimum__c;
        symCase.sym_outputTier__c = census.sym_outputTier__c;
        symCase.Sym_Participation_Rate__c = census.Sym_ParticipationRate__c;
        symCase.Sym_Payment_Account_Type__c = billingAdminPreferences.Sym_Payment_Account_Type__c;
        symCase.Sym_Payment_preference__c = billingAdminPreferences.Sym_Payment_preference__c;
        symCase.Sym_Pharmacy_Tier_1_coinsur_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_1_coinsur_max__c;
        symCase.Sym_Pharmacy_Tier_1_coinsur_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_1_coinsur_min__c;
        symCase.Sym_Pharmacy_Tier_1_copay_max2__c = fineTuneRecommendation.Sym_Pharmacy_Tier_1_copay_max2__c;
        symCase.Sym_Pharmacy_Tier_1_copay_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_1_copay_min__c;
        symCase.Sym_Pharmacy_Tier_2_coinsur_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_2_coinsur_max__c;
        symCase.Sym_Pharmacy_Tier_2_coinsur_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_2_coinsur_min__c;
        symCase.Sym_Pharmacy_Tier_2_copay_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_2_copay_max__c;
        symCase.Sym_Pharmacy_Tier_2_copay_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_2_copay_min__c;
        symCase.Sym_Pharmacy_Tier_3_coinsur_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_3_coinsur_max__c;
        symCase.Sym_Pharmacy_Tier_3_coinsur_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_3_coinsur_min__c;
        symCase.Sym_Pharmacy_Tier_3_copay_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_3_copay_max__c;
        symCase.Sym_Pharmacy_Tier_3_copay_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_3_copay_min__c;
        symCase.Sym_Pharmacy_Tier_4_coinsur_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_4_coinsur_max__c;
        symCase.Sym_Pharmacy_Tier_4_Coinsur_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_4_Coinsur_min__c;
        symCase.Sym_Pharmacy_Tier_4_copay_max__c = fineTuneRecommendation.Sym_Pharmacy_Tier_4_copay_max__c;
        symCase.Sym_Pharmacy_Tier_4_copay_min__c = fineTuneRecommendation.Sym_Pharmacy_Tier_4_copay_min__c;
        symCase.Sym_POS_Medical_Plan__c = fineTuneRecommendation.Sym_POS_Medical_Plan__c;
        symCase.Sym_PPO_Medical_Plan__c = fineTuneRecommendation.Sym_PPO_Medical_Plan__c;
        symCase.Sym_Prescription_Coinsurance_Maximum__c = fineTuneRecommendation.Sym_Prescription_Coinsurance_Maximum__c;
        symCase.Sym_Prescription_Coinsurance_Minimum__c = fineTuneRecommendation.Sym_Prescription_Coinsurance_Minimum__c;
        symCase.Sym_Prescription_Copay_maximum__c = fineTuneRecommendation.Sym_Prescription_Copay_maximum__c;
        symCase.Sym_Prescription_Copay_minimum__c = fineTuneRecommendation.Sym_Prescription_Copay_minimum__c;
        symCase.sym_primary_contact_email__c = quote.Sym_Employer_Main_Contact_Email__c;
        symCase.sym_primary_first_name__c = quote.Contact.FirstName;
        symCase.Sym_primary_contact_id__c = quote.ContactId;
        symCase.sym_primary_contact_last_name__c = quote.Contact.LastName;
        symCase.sym_primary_contact_phone__c = quote.Contact.Phone;
        symCase.Sym_Prioritize_Medical_Plans__c = fineTuneRecommendation.Sym_Prioritize_Medical_Plans__c;
        symCase.sym_quote_id__c = quoteId;
        symCase.sym_quote_status__c = quote.Symphony_Status__c;
        symCase.Sym_Recommendation_Strength__c = fineTuneRecommendation.Sym_Recommendation_Strength__c;
        symCase.Sym_Routing_Number__c = billingAdminPreferences.Sym_Routing_Number__c;
        symCase.Sym_Self_Billing__c = billingAdminPreferences.Sym_Self_Billing__c;
        //symCase.sym_sic__c = quote.Account.Sic;
        symCase.sym_sic__c = quote.Account.SicDesc;
        symCase.State__c = quote.Account.BillingState;
        symCase.Sym_Target_Deductible_Family_INN__c = summaryOfBenefits.Sym_Target_Deductible_Family_INN__c;
        symCase.Sym_Target_Deductible_Family_ONN__c = summaryOfBenefits.Sym_Target_Deductible_Family_ONN__c;
		symCase.Sym_Target_Deductible_Family_OON__c = summaryOfBenefits.Sym_Target_Deductible_Family_OON__c;
        symCase.Sym_Target_Deductible_Individual_INN__c = summaryOfBenefits.Sym_Target_Deductible_Individual_INN__c;
        symCase.Sym_Target_Deductible_Individual_OON__c = summaryOfBenefits.Sym_Target_Deductible_Individual_OON__c;
        symCase.Sym_Target_INN_Coinsurance__c = summaryOfBenefits.Sym_Target_INN_Coinsurance__c;
        symCase.Sym_Target_OON_Coinsurance__c = summaryOfBenefits.Sym_Target_OON_Coinsurance__c;
        symCase.Sym_Target_OOP_Max_Family_INN__c = summaryOfBenefits.Sym_Target_OOP_Max_Family_INN__c;
        symCase.Sym_Target_OOP_Max_Family_OON__c = summaryOfBenefits.Sym_Target_OOP_Max_Family_OON__c;
        symCase.Sym_Target_OOP_Max_Individual_INN__c = summaryOfBenefits.Sym_Target_OOP_Max_Individual_INN__c;
        symCase.Sym_Target_OOP_Max_Individual_OON__c = summaryOfBenefits.Sym_Target_OOP_Max_Individual_OON__c;
        symCase.Sym_Target_Rx_Tier_Four_Coinsurance__c = summaryOfBenefits.Sym_Target_Rx_Tier_Four_Coinsurance__c;
        symCase.Sym_Target_Rx_Tier_Four_Copay__c = summaryOfBenefits.Sym_Target_Rx_Tier_Four_Copay__c;
        symCase.Sym_Target_Rx_Tier_One_Coinsurance__c = summaryOfBenefits.Sym_Target_Rx_Tier_One_Coinsurance__c;
        symCase.Sym_Target_Rx_Tier_One_Copay__c = summaryOfBenefits.Sym_Target_Rx_Tier_One_Copay__c;
        symCase.Sym_Target_Rx_Tier_Three_Coinsurance__c = summaryOfBenefits.Sym_Target_Rx_Tier_Three_Coinsurance__c;
        symCase.Sym_Target_Rx_Tier_Three_Copay__c = summaryOfBenefits.Sym_Target_Rx_Tier_Three_Copay__c;
        symCase.Sym_Target_Rx_Tier_Two_Coinsurance__c = summaryOfBenefits.Sym_Target_Rx_Tier_Two_Coinsurance__c;
        symCase.Sym_Target_Rx_Tier_Two_Copay__c = summaryOfBenefits.Sym_Target_Rx_Tier_Two_Copay__c;
        symCase.Total_Average_Age__c = census.Sym_Average_age_of_Employees__c;
        symCase.Sym_Total_Average_Premium__c = summaryOfBenefits.Sym_Total_Average_Premium__c;
        symCase.Sym_Total_Deductible_Family_INN__c = summaryOfBenefits.Sym_Total_Deductible_Family_INN__c;
        symCase.Sym_Total_Deductible_Family_OON__c = summaryOfBenefits.Sym_Total_Deductible_Family_OON__c;
        symCase.Sym_Total_Dependents_Org__c = census.Sym_Total_Dependents_Org__c;
        symCase.Sym_Total_OOP_Max_Individual_in_Network__c = summaryOfBenefits.Sym_Total_OOP_Max_Individual_in_Network__c;
        symCase.Total_Subscriber_Count_Org__c = census.Sym_Total_Subscriber_Count_Org__c;
        symCase.Sym_Waiting_Period__c = billingAdminPreferences.Sym_Waiting_Period__c;
		symCase.Sym_Quote__c = quoteId;
        
        insert symCase;

        //Better spot to be found for this but ok for now
        sendCustomerMaster(quoteId);
    }

    @future(callout=true)
    public static void sendCustomerMaster(Id quoteId) {
        String payload = [SELECT Body FROM StaticResource WHERE Name = 'Customer_Master_Payload'].Body.toString();
        payload = payload.replace('"SF10000112"', '"' + quoteId + '"');
        payload = payload.replace('"12121111"', '"' + quoteId + '"');
        payload = payload.replace('"af31049"', '"AG33320"');
        AnthemAPI.sendCustomerMaster(payload);
    }

}