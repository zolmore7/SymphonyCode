public with sharing class symphonyCoLo3Demo {
    @InvocableMethod(label='Call Recommendation')
    public static List<string> sendRecommendation(List <Id> quoteId) {
        Quote theQuote = [SELECT Id, Account.Id, Opportunity.Id, Symphony_Status__c 
        FROM Quote 
        WHERE id = :quoteId[0] LIMIT 1];
        Account theAccount = [SELECT Id, Name, County__c, SicDesc, BillingPostalCode 
        FROM Account 
        WHERE id = :theQuote.Account.Id LIMIT 1];
        Sym_Census__c theCensus = [Select Id, Sym_Active_Member_Count__c, Sym_Number_below_20__c, Sym_Number_Between_21_30__c,
        Sym_Number_between_31_40__c, Sym_Number_between_41_50__c, Sym_Number_between_51_60__c, Sym_Number_Employee_Spouse__c, Sym_Number_of_family_plans__c,
        Sym_Number_of_Female__c, Sym_Number_of_individual_plans__c, Sym_Number_of_Male__c, Sym_Number_over_60__c, Sym_employeeChildrenPMPM__c,
        Sym_employeeSpousePMPM__c, Sym_familyPMPM__c , Sym_indvidualPMPM__c, Sym_Employee_with_dependents__c, Sym_Number_of_Plans__c, Sym_State__c,
        Sym_Total_Average_Age__c, Sym_Total_Dependents_Org__c, Sym_Total_Subscriber_Count_Org__c
        FROM Sym_Census__c
        WHERE Sym_Account__c = :theAccount.id LIMIT 1];
        Sym_Summary_of_Benefits__c theEOB = [SELECT Id, Sym_Current_Coinsurance_INN__c, Sym_Current_Coinsurance_OON__c,
        Sym_Current_Family_Deductible_In_Network__c, Sym_Current_Family_Deductible_OON__c, Sym_Current_Individual_Deduct_In_Network__c,
        Sym_Current_Individual_Deductible_OON__c, Sym_Current_OOP_max_Family_INN__c, Sym_Current_OOP_max_Family_OON__c,
        Sym_Current_OOP_max_Individual_INN__c,Sym_Current_Rx_Tier_Four_Coinsurance__c, Sym_Current_Rx_Tier_Four_Copay__c,
        Sym_Current_Rx_Tier_One_Coinsurance__c, Sym_Current_Rx_Tier_One_Copay__c, Sym_Current_Rx_Tier_Three_Coinsurance__c,
        Sym_Current_Rx_Tier_Three_Copay__c, Sym_Current_Rx_Tier_Two_Coinsurance__c, Sym_Current_Rx_Tier_Two_Copay__c,
        Sym_Current_OOP_max_Individual_OON__c
        FROM Sym_Summary_of_Benefits__c
        WHERE Sym_Account__c = :theAccount.id LIMIT 1];
        Sym_Fine_Tune_Recommendation__c theFT = [SELECT Id, Sym_Family_In_Network_Deductible_Max__c,
        Sym_Fam_Out_Network_Deductible_Max__c, Sym_Indivdl_Ddtbl_InNet_Max__c,
        Sym_Indvl_Out_Network_Ddct_Max__c, Sym_Out_Network_Coinsurance_Maximum__c,
        Sym_In_Network_Coinsurance_Maximum__c, Sym_Family_Max_OoP_in_ntwrk_max__c,
        Sym_Family_Max_OoP_ot_ntwrk_max__c, Sym_Indvdl_Max_OoP_in_ntwrk_max__c,
        Sym_Indvdl_Max_OoP_ot_ntwrk_max__c, Sym_HMO_Medical_Plan__c,
        Sym_HSA_Medical_Plan__c, Sym_POS_Medical_Plan__c, Sym_PPO_Medical_Plan__c,
        Sym_Pharmacy_Tier_1_coinsur_max__c, Sym_Pharmacy_Tier_1_copay_max2__c,
        Sym_Pharmacy_Tier_2_coinsur_max__c, Sym_Pharmacy_Tier_2_copay_max__c,
        Sym_Pharmacy_Tier_3_coinsur_max__c, Sym_Pharmacy_Tier_3_copay_max__c,
        Sym_Pharmacy_Tier_4_coinsur_max__c, Sym_Pharmacy_Tier_4_copay_max__c        
        FROM Sym_Fine_Tune_Recommendation__c
        WHERE Sym_Account__c = :theAccount.Id];
        AnthemAPI.RecommendationRequest recommendationRequest = new AnthemAPI.RecommendationRequest();
        recommendationRequest.activeMemberCount = integer.valueOf(theCensus.Sym_Active_Member_Count__c);
        //recommendationRequest.county = theAccount.County__c;
        recommendationRequest.county = 'FRANKLIN';
        recommendationRequest.currentCoinsuranceINN = theEOB.Sym_Current_Coinsurance_INN__c / 100;
        recommendationRequest.currentCoinsuranceOON = theEOB.Sym_Current_Coinsurance_OON__c / 100;
        recommendationRequest.currentFamilyDeductibleINN = integer.valueOf(theEOB.Sym_Current_Family_Deductible_In_Network__c);
        recommendationRequest.currentFamilyDeductibleOON = integer.valueOf(theEOB.Sym_Current_Family_Deductible_OON__c);
        recommendationRequest.currentIndividualDeductibleINN = integer.valueOf(theEOB.Sym_Current_Individual_Deduct_In_Network__c);
        recommendationRequest.currentIndividualDeductibleOON = integer.valueOf(theEOB.Sym_Current_Individual_Deductible_OON__c);
        recommendationRequest.currentOOPmaxFamilyINN = integer.valueof(theEOB.Sym_Current_OOP_max_Family_INN__c);
        recommendationRequest.currentOOPmaxFamilyOON = integer.valueof(theEOB.Sym_Current_OOP_max_Family_OON__c);
        recommendationRequest.currentOOPmaxIndividualINN = integer.valueof(theEOB.Sym_Current_OOP_max_Individual_INN__c);
        recommendationRequest.currentOOPmaxIndividualOON = integer.valueof(theEOB.Sym_Current_OOP_max_Individual_OON__c);
        recommendationRequest.currentRxTierFourCoinsurance = -1;
        recommendationRequest.currentRxTierFourCopay = integer.valueof(theEOB.Sym_Current_Rx_Tier_Four_Copay__c / 100);
        recommendationRequest.currentRxTierOneCoinsurance = -1;
        recommendationRequest.currentRxTierOneCopay = integer.valueOf(theEOB.Sym_Current_Rx_Tier_One_Copay__c);
        recommendationRequest.currentRxTierThreeCoinsurance = -1;
        recommendationRequest.currentRxTierThreeCopay = integer.valueOf(theEOB.Sym_Current_Rx_Tier_Three_Copay__c);
        recommendationRequest.currentRxTierTwoCoinsurance = -1;
        recommendationRequest.currentRxTierTwoCopay = integer.valueOf(theEOB.Sym_Current_Rx_Tier_Two_Copay__c);
        recommendationRequest.effectiveDt = '01/01/2020';
        recommendationRequest.employeeChildrenPMPM = theCensus.Sym_employeeChildrenPMPM__c;
        recommendationRequest.employeeSpousePMPM = theCensus.Sym_employeeSpousePMPM__c;
        recommendationRequest.familyPMPM = theCensus.Sym_familyPMPM__c;
        recommendationRequest.indvidualPMPM = theCensus.Sym_indvidualPMPM__c;
        //if(theFT.Sym_HMO_Medical_Plan__c) {
        //    recommendationRequest.memberSelectionCategory = 'HMO';
        //} else if(theFT.Sym_PPO_Medical_Plan__c) {
        //    recommendationRequest.memberSelectionCategory = 'PPO';
        //} else if(theFT.Sym_POS_Medical_Plan__c) {
        //    recommendationRequest.memberSelectionCategory = 'POS';
        //} else if(theFT.Sym_HSA_Medical_Plan__c) {
        //    recommendationRequest.memberSelectionCategory = 'HSA';
        //} else {
            recommendationRequest.memberSelectionCategory = 'ALL';
        //}
        recommendationRequest.numberBelow20 = integer.valueOf(theCensus.Sym_Number_below_20__c);
        recommendationRequest.numberBetween21And30 = integer.valueOf(theCensus.Sym_Number_Between_21_30__c);
        recommendationRequest.numberBetween31And40 = integer.valueOf(theCensus.Sym_Number_between_31_40__c);
        recommendationRequest.numberBetween41And50 = integer.valueOf(theCensus.Sym_Number_between_41_50__c);
        recommendationRequest.numberBetween51And60 = integer.valueOf(theCensus.Sym_Number_between_51_60__c);
        recommendationRequest.numberEK = integer.ValueOf(theCensus.Sym_Employee_with_dependents__c);
        recommendationRequest.numberES = integer.valueOf(theCensus.Sym_Number_Employee_Spouse__c);
        recommendationRequest.numberFamilyPlans = integer.valueOf(theCensus.Sym_Number_of_family_plans__c);
        recommendationRequest.numberFemale = integer.valueOf(theCensus.Sym_Number_of_Female__c);
        recommendationRequest.numberIndividualPlans = integer.valueOf(theCensus.Sym_Number_of_individual_plans__c);
        recommendationRequest.numberMale = integer.valueOf(theCensus.Sym_Number_of_Male__c);
        recommendationRequest.numberOver60 = integer.valueOf(theCensus.Sym_Number_over_60__c);
        recommendationRequest.numbOfPlans = integer.valueOf(theCensus.Sym_Number_of_Plans__c);
        //recommendationRequest.sicCd = integer.ValueOf(theAccount.SicDesc.SubStringBefore(' '));
        //recommendationRequest.sicDivision = theAccount.SicDesc.SubStringAfter(' ');
        recommendationRequest.sicCd = 2074;
        recommendationRequest.sicDivision = 'Services';

        recommendationRequest.stateCode = theCensus.Sym_State__c;
        recommendationRequest.targetDeductibleFamilyINN = integer.ValueOf(theFT.Sym_Family_In_Network_Deductible_Max__c);
        recommendationRequest.targetDeductibleFamilyOON = integer.ValueOf(theFT.Sym_Fam_Out_Network_Deductible_Max__c);
        recommendationRequest.targetDeductibleIndividualINN = integer.ValueOf(theFT.Sym_Indivdl_Ddtbl_InNet_Max__c);
        recommendationRequest.targetDeductibleIndividualOON = integer.ValueOf(theFT.Sym_Indvl_Out_Network_Ddct_Max__c);
        recommendationRequest.targetINNCoinsurance = theFT.Sym_In_Network_Coinsurance_Maximum__c / 100;
        recommendationRequest.targetOONCoinsurance = theFT.Sym_Out_Network_Coinsurance_Maximum__c / 100;
        recommendationRequest.targetOOPMaxFamilyINN = integer.ValueOf(theFT.Sym_Family_Max_OoP_in_ntwrk_max__c);
        recommendationRequest.targetOOPMaxFamilyOON = integer.ValueOf(theFT.Sym_Family_Max_OoP_ot_ntwrk_max__c);
        recommendationRequest.targetOOPMaxIndividualINN = integer.ValueOf(theFT.Sym_Indvdl_Max_OoP_in_ntwrk_max__c);
        recommendationRequest.targetOOPMaxIndividualOON = integer.ValueOf(theFT.Sym_Indvdl_Max_OoP_ot_ntwrk_max__c);
        recommendationRequest.targetRxTierFourCoinsurance = -1;
        recommendationRequest.targetRxTierFourCopay = integer.valueOf(theFt.Sym_Pharmacy_Tier_4_copay_max__c);
        recommendationRequest.targetRxTierOneCoinsurance = -1;
        recommendationRequest.targetRxTierOneCopay = integer.valueOf(theFt.Sym_Pharmacy_Tier_1_copay_max2__c);
        recommendationRequest.targetRxTierThreeCoinsurance = -1;
        recommendationRequest.targetRxTierThreeCopay = integer.valueOf(theFt.Sym_Pharmacy_Tier_3_copay_max__c);
        recommendationRequest.targetRxTierTwoCoinsurance = -1;
        recommendationRequest.targetRxTierTwoCopay = integer.valueOf(theFt.Sym_Pharmacy_Tier_2_copay_max__c);
        recommendationRequest.totalAvgAge = integer.valueOf(theCensus.Sym_Total_Average_Age__c);
        recommendationRequest.totalDpndntOrg = integer.valueOf(theCensus.Sym_Total_Dependents_Org__c);
        recommendationRequest.totalSbscrbrCntOrg = integer.valueOf(theCensus.Sym_Total_Subscriber_Count_Org__c);
        //recommendationRequest.zipCode = integer.valueOf(theAccount.BillingPostalCode);
        recommendationRequest.zipCode = 45226;
        system.debug(recommendationRequest);
        AnthemAPI.RecommendationResponse recommendationResponse = AnthemAPI.getRecommendations(recommendationRequest);

        List<AnthemAPI.Plan> thePopularPlans = recommendationResponse.popularPlan;
        List<AnthemAPI.Plan> theRecommendedPlans = recommendationResponse.recommendedPlans;

        String temp = '';
        List<Product2> returnedProducts = new List<Product2>();
        List<String> product2Ids = new List<String>();

        List<String> theResult = new List<String>();
        if(thePopularPlans == null && theRecommendedPlans == null) {
            //theResult.add('No matching plans');
            theResult.add(recommendationResponse.toString());
        } else {
            List<QuoteLineItem> delQLIs = [SELECT Id FROM QuoteLineItem WHERE QuoteId=:theQuote.Id];
            delete(delQLIs);

            for(AnthemApi.Plan p: thePopularPlans) {
                product2Ids.add(p.contractCd);
            }
            for(AnthemApi.Plan p: theRecommendedPlans) {
                product2Ids.add(p.contractCd);
            }
            returnedProducts = [SELECT Id, Name, Contract_Code__c FROM Product2 WHERE Contract_Code__c IN :product2Ids];

            List<QuoteLineItem> newQLIs = new List<QuoteLineItem>();

           for(Product2 p : returnedProducts) {
                QuoteLineItem q = new QuoteLineItem(
                    PricebookEntryId='01u1K00000bi4tcQAA', Product2Id=p.Id, Opportunity__c=theQuote.Opportunity.Id,
                    ProductStage__c='In Progress', Quantity=1, QuoteId=theQuote.Id, UnitPrice=950
                );
                newQLIs.add(q);
            }

            insert(newQLIs);
            theQuote.Symphony_Status__c = 'Get Rate';
            update(theQuote);
            theResult.add(recommendationResponse.toString());
        }
        
        return theResult; 
    }
}