public with sharing class symphonyGetFineTuneRecommendations {
    @AuraEnabled(cacheable=true)
    public static Sym_Fine_Tune_Recommendation__c symphonyGetFineTuneRecommendations(Id recordId) {
        Sym_Fine_Tune_Recommendation__c fineTuneRecord = [SELECT Id, Sym_Family_In_Network_Deductible_Max__c,
        Sym_Family_In_Network_Deductible_Min__c,Sym_PPO_Medical_Plan__c,Sym_HMO_Medical_Plan__c,
        Sym_POS_Medical_Plan__c, Sym_HSA_Medical_Plan__c,Sym_Fam_Out_Network_Deductible_Min__c,
        Sym_Fam_Out_Network_Deductible_Max__c,Sym_Invdl_Out_Ntwk_Dtbl_Min__c, Sym_Indvdl_In_Ntwk_Deduct_Min__c,
        Sym_Indvl_Out_Network_Ddct_Max__c, Sym_Indivdl_Ddtbl_InNet_Max__c, Sym_Indvdl_Max_OoP_in_ntwrk_max__c,
        Sym_Individual_Max_OoP_in_ntwrk__c, Sym_Indvdl_Max_OoP_ot_ntwrk_min__c, Sym_Indvdl_Max_OoP_ot_ntwrk_max__c,
        Sym_Family_Max_OoP_in_ntwrk_max__c, Sym_Family_Max_Oo_in_ntwrk_min__c, Sym_Family_Max_OoP_ot_ntwrk_min__c,
        Sym_Family_Max_OoP_ot_ntwrk_max__c, Sym_In_Network_Coinsurance_Maximum__c,Sym_In_Network_Coinsurance_Minimum__c,
        Sym_Out_Network_Coinsurance_Maximum__c, Sym_Out_Network_Coinsurance_Minimum__c, Sym_Pharmacy_Tier_1_coinsur_min__c,
        Sym_Pharmacy_Tier_1_coinsur_max__c, Sym_Pharmacy_Tier_2_coinsur_min__c, Sym_Pharmacy_Tier_2_coinsur_max__c,
        Sym_Pharmacy_Tier_3_coinsur_min__c, Sym_Pharmacy_Tier_3_coinsur_max__c, Sym_Pharmacy_Tier_4_Coinsur_min__c,
        Sym_Pharmacy_Tier_4_coinsur_max__c, Sym_Pharmacy_Tier_1_copay_min__c, Sym_Pharmacy_Tier_1_copay_max2__c,
        Sym_Pharmacy_Tier_2_copay_min__c, Sym_Pharmacy_Tier_2_copay_max__c, Sym_Pharmacy_Tier_3_copay_min__c,
        Sym_Pharmacy_Tier_3_copay_max__c, Sym_Pharmacy_Tier_4_copay_min__c, Sym_Pharmacy_Tier_4_copay_max__c,
        Sym_Data_sets_visible_to_client__c
        FROM Sym_Fine_Tune_Recommendation__c
        WHERE Sym_Account__c = :recordId];

        return fineTuneRecord;
    } 

    @AuraEnabled()
    public static String symphonySaveFineTuneRecommendations(Id recordId, Boolean PPOCheck, Boolean HMOCheck, Boolean POSCheck, Boolean HSACheck, FineTuneSave fineTuneSave) {

        Sym_Fine_Tune_Recommendation__c recommendationRecord = [Select Id, Sym_Account__c
        FROM Sym_Fine_Tune_Recommendation__c 
        WHERE Sym_Account__c = :recordId];

        String returnMessage = 'Success';

        system.debug(recordId);
        system.debug(fineTuneSave);

        recommendationRecord.Sym_PPO_Medical_Plan__c = PPOCheck;
        recommendationRecord.Sym_HMO_Medical_Plan__c = HMOCheck;
        recommendationRecord.Sym_POS_Medical_Plan__c = POSCheck;
        recommendationRecord.Sym_HSA_Medical_Plan__c = HSACheck;
        recommendationRecord.Sym_Indivdl_Ddtbl_InNet_Max__c = fineTuneSave.amountIndDedInNetwork;
        recommendationRecord.Sym_Indvl_Out_Network_Ddct_Max__c = fineTuneSave.amountIndDedOutNetwork;
        recommendationRecord.Sym_Family_In_Network_Deductible_Max__c = fineTuneSave.amountFamDedInNetwork;
        recommendationRecord.Sym_Fam_Out_Network_Deductible_Max__c = fineTuneSave.amountFamDedOutNetwork;
        recommendationRecord.Sym_Indvdl_Max_OoP_in_ntwrk_max__c = fineTuneSave.amountIndMOOPInNetwork;       
        recommendationRecord.Sym_Indvdl_Max_OoP_ot_ntwrk_max__c = fineTuneSave.amountIndMOOPOutNetwork;
        recommendationRecord.Sym_Family_Max_OoP_in_ntwrk_max__c = fineTuneSave.amountFamMOOPInNetwork;
        recommendationRecord.Sym_Family_Max_OoP_ot_ntwrk_max__c = fineTuneSave.amountFamMOOPOutNetwork;
        recommendationRecord.Sym_In_Network_Coinsurance_Maximum__c = fineTuneSave.amountInNetworkCoinsurance;
        recommendationRecord.Sym_Out_Network_Coinsurance_Maximum__c = fineTuneSave.amountOutNetworkCoinsurance;
        recommendationRecord.Sym_Pharmacy_Tier_1_coinsur_max__c = fineTuneSave.amountPharmTier1Coinsurance;
        recommendationRecord.Sym_Pharmacy_Tier_2_coinsur_max__c = fineTuneSave.amountPharmTier2Coinsurance;
        recommendationRecord.Sym_Pharmacy_Tier_3_coinsur_max__c = fineTuneSave.amountPharmTier3Coinsurance;
        recommendationRecord.Sym_Pharmacy_Tier_4_coinsur_max__c = fineTuneSave.amountPharmTier4Coinsurance;
        recommendationRecord.Sym_Pharmacy_Tier_1_copay_max2__c = fineTuneSave.amountPharmTier1Copay;
        recommendationRecord.Sym_Pharmacy_Tier_2_copay_max__c = fineTuneSave.amountPharmTier2Copay;
        recommendationRecord.Sym_Pharmacy_Tier_3_copay_max__c = fineTuneSave.amountPharmTier3Copay;
        recommendationRecord.Sym_Pharmacy_Tier_4_copay_max__c = fineTuneSave.amountPharmTier4Copay;

        try {
            update recommendationRecord;
        } catch(DmlException e) {
            returnMessage = e.getMessage();
        }
        system.debug(returnMessage);
        return returnMessage;
    }

    public class FineTuneSave {
        @AuraEnabled public Integer amountIndDedInNetwork {get; set;}
        @AuraEnabled public Integer amountIndDedOutNetwork {get; set;}
        @AuraEnabled public Integer amountFamDedInNetwork {get; set;}
        @AuraEnabled public Integer amountFamDedOutNetwork {get; set;}
        @AuraEnabled public Integer amountIndMOOPInNetwork {get; set;}
        @AuraEnabled public Integer amountIndMOOPOutNetwork {get; set;}
        @AuraEnabled public Integer amountFamMOOPInNetwork {get; set;}
        @AuraEnabled public Integer amountFamMOOPOutNetwork {get; set;}
        @AuraEnabled public Integer amountInNetworkCoinsurance {get; set;}
        @AuraEnabled public Integer amountOutNetworkCoinsurance {get; set;}
        @AuraEnabled public Integer amountPharmTier1Coinsurance {get; set;}
        @AuraEnabled public Integer amountPharmTier2Coinsurance {get; set;}
        @AuraEnabled public Integer amountPharmTier3Coinsurance {get; set;}
        @AuraEnabled public Integer amountPharmTier4Coinsurance {get; set;}
        @AuraEnabled public Integer amountPharmTier1Copay {get; set;}
        @AuraEnabled public Integer amountPharmTier2Copay {get; set;}
        @AuraEnabled public Integer amountPharmTier3Copay {get; set;}
        @AuraEnabled public Integer amountPharmTier4Copay {get; set;}
    }
}