/*
 * Symphony Recommended Plans API
 * 
 * POST /recPlans
 * 
 */
@RestResource(urlMapping='/symphony/recPlans/*')
global with sharing class APISymphonyRecPlans {

    // This fails because callouts can invoke code that makes callouts:
    // https://help.salesforce.com/articleView?id=000340086&type=1&mode=1
    @future(callout=true)
    public static void apiTest() {
        String endpoint = 'https://commercial--POCarchima.cs24.my.salesforce.com/services/apexrest/symphony/recPlans/';

        Map<String, Object> payload = new Map<String, Object>{
            'quoteId' => '0Q041000000zreE',
            'recommendationRequest' => new AnthemAPI.RecommendationRequest(),
            'memberInfoRoster' => new List<APISymphonyRecPlans.MemberInfo>()
        };
        
        HttpRequest httpRequest = new HttpRequest();
		httpRequest.setTimeout(60 * 1000);
		httpRequest.setEndpoint(endpoint);
		httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

		httpRequest.setBody(JSON.serialize(payload));

        System.debug('### REQUEST BODY=' + httpRequest.getBody());

        HttpResponse httpResponse = new Http().send(httpRequest);

        System.debug('### RESPONSE STATUS CODE=' + httpResponse.getStatusCode());
        System.debug('### RESPONSE BODY=' + httpResponse.getBody());
    }
    
    @HttpPost
    global static FindPlansResponse findRecommendedPlans(Id quoteId, AnthemAPI.RecommendationRequest recommendationRequest, List<MemberInfo> memberInfoRoster) {
        System.debug('FIND\n\n' + JSON.serialize(recommendationRequest) + '\n\n' + JSON.serialize(memberInfoRoster));

        // Make call to the recommendations API and store response.
        getRecommendedPlans(quoteId, recommendationRequest, memberInfoRoster);

        // Make an asynchronous call to the ratings API.
        getRatesAsync(quoteId);
        
        FindPlansResponse findPlansResponse = new FindPlansResponse();
        
        findPlansResponse.symphonyStatus = [SELECT Symphony_Status__c FROM Quote WHERE Id = :quoteId].Symphony_Status__c;

        return findPlansResponse; 
    }

    public static void getRecommendedPlans(Id quoteId, AnthemAPI.RecommendationRequest recommendationRequest, List<MemberInfo> memberInfoRoster) {
        // Make API call to get recommendations.
		AnthemAPI.RecommendationResponse recommendationResponse = AnthemAPI.getRecommendations(recommendationRequest);

        if (recommendationResponse.popularPlan != null && recommendationResponse.recommendedPlans != null) {
            Quote quote = [SELECT OpportunityId FROM Quote WHERE Id = :quoteId];
            quote.Symphony_Status__c = 'Get Rate';
            update quote;

            Set<String> contractCodes = new Set<String>();
            
            for (AnthemApi.Plan plan : recommendationResponse.popularPlan) {
                contractCodes.add(plan.contractCd);
            }

            for(AnthemApi.Plan plan : recommendationResponse.recommendedPlans) {
                contractCodes.add(plan.contractCd);
            }

            List<PricebookEntry> pricebookEntries = [
                SELECT
                	Product2.Contract_Code__c, Product2Id
                FROM
                	PricebookEntry
                WHERE
                	Product2.Contract_Code__c IN :contractCodes
            ];

            Map<String, PricebookEntry> contractCodePricebookEntries = new Map<String, PricebookEntry>();

			for (PricebookEntry pricebookEntry : pricebookEntries) {
                contractCodePricebookEntries.put(pricebookEntry.Product2.Contract_Code__c, pricebookEntry);
            }

            List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
            
            for (Integer i = 1; i <= recommendationResponse.popularPlan.size(); i++) {
                AnthemAPI.Plan plan = recommendationResponse.popularPlan[i - 1];
                PricebookEntry pricebookEntry = contractCodePricebookEntries.get(plan.contractCd);
                
                QuoteLineItem quoteLineItem = new QuoteLineItem();
                quoteLineItem.QuoteId = quote.Id;
                quoteLineItem.PricebookEntryId = pricebookEntry.Id;
                quoteLineItem.Product2Id = pricebookEntry.Product2Id;
                quoteLineItem.Opportunity__c = quote.OpportunityId;
                quoteLineItem.ProductStage__c = 'In Progress';
                quoteLineItem.Quantity = 1;
                quoteLineItem.UnitPrice = 950; // Should this come from PBE?
                quoteLineItem.Sym_Recommendation__c = true;
                quoteLineItem.Sym_Recommendation_Type__c = 'Popular';
                quoteLineItem.Sym_Recommendation_Order__c = i;
                quoteLineItems.add(quoteLineItem);
            }

            for (Integer i = 1; i <= recommendationResponse.recommendedPlans.size(); i++) {
                AnthemAPI.Plan plan = recommendationResponse.recommendedPlans[i - 1];
                PricebookEntry pricebookEntry = contractCodePricebookEntries.get(plan.contractCd);

                QuoteLineItem quoteLineItem = new QuoteLineItem();
                quoteLineItem.QuoteId = quote.Id;
                quoteLineItem.PricebookEntryId = pricebookEntry.Id;
                quoteLineItem.Product2Id = pricebookEntry.Product2Id;
                quoteLineItem.Opportunity__c = quote.OpportunityId;
                quoteLineItem.ProductStage__c = 'In Progress';
                quoteLineItem.Quantity = 1;
                quoteLineItem.UnitPrice = 950; // Should this come from PBE?
                quoteLineItem.Sym_Recommendation__c = true;
                quoteLineItem.Sym_Recommendation_Type__c = 'Recommended';
                quoteLineItem.Sym_Recommendation_Order__c = i;
                quoteLineItems.add(quoteLineItem);
            } 

            // Delete existing Quote Line Items.
            delete [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quoteId];
            
            // Insert new Quote Line Items.
            insert quoteLineItems; 
        }

        // Store recommendation request data.
		storeData(quoteId, recommendationRequest, memberInfoRoster); 
    }

    public static void storeData(Id quoteId, AnthemAPI.RecommendationRequest recommendationRequest, List<MemberInfo> memberInfoRoster) {
        Quote quote = [SELECT AccountId FROM Quote WHERE Id = :quoteId];

        Account account = new Account(Id=quote.AccountId);
        account.BillingPostalCode = String.valueOf(recommendationRequest.zipCode);
        account.county__c = recommendationRequest.county;
        account.SicDesc = recommendationRequest.sicCd + ' ' + recommendationRequest.sicDivision;
        update account;

        Sym_Census__c census;
            
        List<Sym_Census__c> censuses = [SELECT Id FROM Sym_Census__c WHERE Sym_Account__c = :account.Id LIMIT 1];
        if (censuses.size() > 0) {
            census = censuses[0];
        } else {
            census = new Sym_Census__c();
            census.Sym_Account__c = account.Id;
        }

		census.Sym_Active_Member_Count__c = recommendationRequest.activeMemberCount;
        census.Sym_employeeChildrenPMPM__c = recommendationRequest.employeeChildrenPMPM;
        census.Sym_employeeSpousePMPM__c = recommendationRequest.employeeSpousePMPM;
        census.Sym_familyPMPM__c = recommendationRequest.familyPMPM;
        census.Sym_indvidualPMPM__c = recommendationRequest.indvidualPMPM;
        census.Sym_Number_below_20__c = recommendationRequest.numberBelow20;
        census.Sym_Number_Between_21_30__c = recommendationRequest.numberBetween21And30;
        census.Sym_Number_between_31_40__c = recommendationRequest.numberBetween31And40;
        census.Sym_Number_between_41_50__c = recommendationRequest.numberBetween41And50;
        census.Sym_Number_between_51_60__c = recommendationRequest.numberBetween51And60;
        census.Sym_Employee_with_dependents__c = recommendationRequest.numberEK;
        census.Sym_Number_Employee_Spouse__c = recommendationRequest.numberES;
        census.Sym_Number_of_family_plans__c = recommendationRequest.numberFamilyPlans;
        census.Sym_Number_of_Female__c = recommendationRequest.numberFemale;
        census.Sym_Number_of_individual_plans__c = recommendationRequest.numberIndividualPlans;
        census.Sym_Number_of_Male__c = recommendationRequest.numberMale;
        census.Sym_Number_over_60__c = recommendationRequest.numberOver60;
        census.Sym_Number_of_Plans__c = recommendationRequest.numbOfPlans;
        census.Sym_State__c = recommendationRequest.stateCode;
        census.Sym_Total_Average_Age__c = recommendationRequest.totalAvgAge;
        census.Sym_Total_Dependents_Org__c = recommendationRequest.totalDpndntOrg;
        census.Sym_Total_Subscriber_Count_Org__c = recommendationRequest.totalSbscrbrCntOrg;
		upsert census;

   		List<Sym_Census_Member__c> censusMembers = new List<Sym_Census_Member__c>();

        for (MemberInfo memberInfo : memberInfoRoster) {
            Sym_Census_Member__c censusMember = new Sym_Census_Member__c();
            censusMember.Sym_Census__c = census.Id;
            censusMember.Sym_First_Name__c = memberInfo.firstName;
            censusMember.Sym_Last_Name__c = memberInfo.lastName;
            censusMember.Sym_Birthday_Text__c = memberInfo.dateOfBirth;
            censusMember.Sym_Gender__c = memberInfo.gender;
            censusMember.Sym_Tier__c = memberInfo.tier;
            censusMember.Sym_Zip_Code__c  = memberInfo.zipCode;
            censusMembers.add(censusMember);
        }

        insert censusMembers; 
        
        Sym_Summary_of_Benefits__c eob;
            
        List<Sym_Summary_of_Benefits__c> eobs = [SELECT Id FROM Sym_Summary_of_Benefits__c WHERE Sym_Account__c = :account.Id LIMIT 1];
        if (eobs.size() > 0) {
            eob = eobs[0];
        } else {
            eob = new Sym_Summary_of_Benefits__c();
            eob.Sym_Account__c = account.Id;
        }

        eob.Sym_Current_Coinsurance_INN__c = multiplyBy(recommendationRequest.currentCoinsuranceINN, 100);
        eob.Sym_Current_Coinsurance_OON__c = multiplyBy(recommendationRequest.currentCoinsuranceOON, 100);
        eob.Sym_Current_Family_Deductible_In_Network__c = recommendationRequest.currentFamilyDeductibleINN;
        eob.Sym_Current_Family_Deductible_OON__c = recommendationRequest.currentFamilyDeductibleOON;
        eob.Sym_Current_Individual_Deduct_In_Network__c = recommendationRequest.currentIndividualDeductibleINN;
        eob.Sym_Current_Individual_Deductible_OON__c = recommendationRequest.currentIndividualDeductibleOON;
        eob.Sym_Current_OOP_max_Family_INN__c = recommendationRequest.currentOOPmaxFamilyINN;
        eob.Sym_Current_OOP_max_Family_OON__c = recommendationRequest.currentOOPmaxFamilyOON;
        eob.Sym_Current_OOP_max_Individual_INN__c = recommendationRequest.currentOOPmaxIndividualINN;
        eob.Sym_Current_OOP_max_Individual_OON__c = recommendationRequest.currentOOPmaxIndividualOON;
        eob.Sym_Current_Rx_Tier_Four_Coinsurance__c = recommendationRequest.currentRxTierFourCoinsurance;
        eob.Sym_Current_Rx_Tier_Four_Copay__c = recommendationRequest.currentRxTierFourCopay;
        eob.Sym_Current_Rx_Tier_One_Coinsurance__c = recommendationRequest.currentRxTierOneCoinsurance;
        eob.Sym_Current_Rx_Tier_One_Copay__c = recommendationRequest.currentRxTierOneCopay;
        eob.Sym_Current_Rx_Tier_Three_Coinsurance__c = recommendationRequest.currentRxTierThreeCoinsurance;
        eob.Sym_Current_Rx_Tier_Three_Copay__c = recommendationRequest.currentRxTierThreeCopay;
        eob.Sym_Current_Rx_Tier_Two_Coinsurance__c = recommendationRequest.currentRxTierTwoCoinsurance;
        eob.Sym_Current_Rx_Tier_Two_Copay__c = recommendationRequest.currentRxTierTwoCopay;
        upsert eob;

        Sym_Fine_Tune_Recommendation__c fineTune;

        List<Sym_Fine_Tune_Recommendation__c> fineTunes = [SELECT Id FROM Sym_Fine_Tune_Recommendation__c WHERE Sym_Account__c = :account.Id LIMIT 1];
        if (fineTunes.size() > 0) {
            fineTune = fineTunes[0];
        } else {
            fineTune = new Sym_Fine_Tune_Recommendation__c();
            fineTune.Sym_Account__c = account.Id;
        }

        fineTune.Sym_Family_In_Network_Deductible_Max__c = recommendationRequest.targetDeductibleFamilyINN;
        fineTune.Sym_Fam_Out_Network_Deductible_Max__c = recommendationRequest.targetDeductibleFamilyOON;
        fineTune.Sym_Indivdl_Ddtbl_InNet_Max__c = recommendationRequest.targetDeductibleIndividualINN;
        fineTune.Sym_Indvl_Out_Network_Ddct_Max__c = recommendationRequest.targetDeductibleIndividualOON;
        fineTune.Sym_In_Network_Coinsurance_Maximum__c = multiplyBy(recommendationRequest.targetINNCoinsurance, 100);
        fineTune.Sym_Out_Network_Coinsurance_Maximum__c = multiplyBy(recommendationRequest.targetOONCoinsurance, 100);
        fineTune.Sym_Family_Max_OoP_in_ntwrk_max__c = recommendationRequest.targetOOPMaxFamilyINN;
        fineTune.Sym_Family_Max_OoP_ot_ntwrk_max__c = recommendationRequest.targetOOPMaxFamilyOON;
        fineTune.Sym_HMO_Medical_Plan__c = (recommendationRequest.memberSelectionCategory == 'HMO');
        fineTune.Sym_HSA_Medical_Plan__c = (recommendationRequest.memberSelectionCategory == 'HSA');
        fineTune.Sym_Indvdl_Max_OoP_in_ntwrk_max__c = recommendationRequest.targetOOPMaxIndividualINN;
        fineTune.Sym_Indvdl_Max_OoP_ot_ntwrk_max__c = recommendationRequest.targetOOPMaxIndividualOON;
        fineTune.Sym_Pharmacy_Tier_4_coinsur_max__c = multiplyGreaterThanZeroBy(recommendationRequest.targetRxTierFourCoinsurance, 100);
        fineTune.Sym_Pharmacy_Tier_4_copay_max__c = recommendationRequest.targetRxTierFourCopay;
        fineTune.Sym_Pharmacy_Tier_1_coinsur_max__c = multiplyGreaterThanZeroBy(recommendationRequest.targetRxTierOneCoinsurance, 100);
        fineTune.Sym_Pharmacy_Tier_1_copay_max2__c = recommendationRequest.targetRxTierOneCopay;
        fineTune.Sym_Pharmacy_Tier_3_coinsur_max__c = multiplyGreaterThanZeroBy(recommendationRequest.targetRxTierThreeCoinsurance, 100);
        fineTune.Sym_Pharmacy_Tier_3_copay_max__c = recommendationRequest.targetRxTierThreeCopay;
        fineTune.Sym_Pharmacy_Tier_2_coinsur_max__c = multiplyGreaterThanZeroBy(recommendationRequest.targetRxTierTwoCoinsurance, 100);
        fineTune.Sym_Pharmacy_Tier_2_copay_max__c = recommendationRequest.targetRxTierTwoCopay;
        fineTune.Sym_PPO_Medical_Plan__c = (recommendationRequest.memberSelectionCategory == 'PPO');
        fineTune.Sym_POS_Medical_Plan__c = (recommendationRequest.memberSelectionCategory == 'POS');
		upsert fineTune; 
    }
    
    @future(callout=true)
    public static void getRatesAsync(Id quoteId) {
        getRates(quoteId);
    }

    public static void getRates(Id quoteId) {
        Quote quote = [
            SELECT
            	Opportunity.Account.Name, Opportunity.Account.SicDesc, Opportunity.Account.BillingPostalCode,
            	(
                    SELECT
                    	Product2.Name, Product2.sym_Symphony_Product_Id__c, Product2.ProductCode, Product2.Contract_Code__c, Product2.LG_Network__c
                    FROM
                    	QuoteLineItemS
                 )
            FROM
            	Quote
            WHERE
            	Id = :quoteId
            LIMIT
            	1
        ];

        List<Sym_Census_Member__c> censusMembers = [
            SELECT 
            	Sym_First_Name__c, Sym_Last_Name__c, Sym_Birthday_Text__c, Sym_Zip_Code__c, Sym_Gender__c, Sym_Tier__c, Sym_Eligibility__c
            FROM
            	Sym_Census_Member__c
            WHERE
            	Sym_Census__r.Sym_Account__c = :quote.Opportunity.AccountId
        ];
        
        AnthemAPI.RatingRequest ratingRequest = new AnthemAPI.RatingRequest();
        ratingRequest.groupName = quote.Opportunity.Account.Name;
        ratingRequest.opportunityID = quote.Opportunity.Id;
        ratingRequest.quoteHeaderID = quote.Id;
        ratingRequest.sicCode = Integer.ValueOf(quote.Opportunity.Account.SicDesc.split(' ')[0]); //Make live
        ratingRequest.state = 'OH';
        ratingRequest.companyZip = Integer.ValueOf(quote.Opportunity.Account.BillingPostalCode);  //Passed in value
        ratingRequest.groupSize = new AnthemAPI.GroupSize();
        ratingRequest.groupSize.maximum = 250;
        ratingRequest.groupSize.minimum = 51;
        ratingRequest.effectiveDate = '2020-01-01';
//        ratingRequest.lob = 'Medical';
        ratingRequest.customerType = 'Prospect';
        ratingRequest.inputTier = 4;
        ratingRequest.outputTier = 4;
        ratingRequest.commissionValue = 0;
        ratingRequest.commissionType = '';
        ratingRequest.chamberOfCommerce = 'NO';
        ratingRequest.participationRate = 0.5;
        ratingRequest.premiumDelay = 30;
        ratingRequest.ratingRequestPlans = new List<AnthemAPI.RatingPlan>();
        ratingRequest.census = new List<AnthemAPI.RatingCensus>();

        for (QuoteLineItem quoteLineItem : quote.QuoteLineItems) {
            AnthemApi.RatingPlan ratingPlan = new AnthemApi.RatingPlan();

            ratingPlan.quoteLineItemID = quoteLineItem.Id;
            ratingPlan.fundingType = 'FI';
            ratingPlan.lob = 'Medical';
			ratingPlan.planName = quoteLineitem.Product2.Name;
            /*if (quoteLineItem.Product2.Contract_Code__c == '51RX') {
                ratingPlan.productID = 42459;
                ratingPlan.contractCode = '50BN';
            } else if (quoteLineItem.Product2.Contract_Code__c == '51QR') {
                ratingPlan.productID = 42447;
                ratingPlan.contractCode = '50L1';
            } else if (quoteLineItem.Product2.Contract_Code__c == '51PF') {
                ratingPlan.productID = 42454;
                ratingPlan.contractCode = '50MA';
            } else { */
                ratingPlan.productID = integerValue(quoteLineItem.Product2.sym_Symphony_Product_Id__c);
                ratingPlan.contractCode = quoteLineItem.Product2.Contract_Code__c;           
            //}

            ratingPlan.networkName = 'Blue Access';
            ratingPlan.networkType = 'PPO';
            //ratingPlan.cdhpIndicator = 'HSA';  //Make live?
            ratingPlan.cdhpIndicator = '';
            ratingRequest.ratingRequestPlans.add(ratingPlan);
        }

        for (Sym_Census_Member__c censusMember : censusMembers) {
            AnthemAPI.RatingCensus ratingCensus = new AnthemAPI.RatingCensus();
            ratingCensus.firstName = censusMember.Sym_First_Name__c;
            ratingCensus.lastName = censusMember.Sym_Last_Name__c;
            //Patch to fix birthday format wrong
            String formattedBirthday = '';
            List<String> thePieces = censusMember.Sym_Birthday_Text__c.split('/');
            formattedBirthday = '19' + thePieces[2] + '-' + thePieces[0] + '-' + thePieces[1];
            ratingCensus.dateOfBirth = formattedBirthday;
            
            //When extract passes correct dates we go back to the original working line below
            //ratingCensus.dateOfBirth = censusMember.Sym_Birthday_Text__c;
            
            
            ratingCensus.zip = Integer.valueOf(censusMember.Sym_Zip_Code__c);
            ratingCensus.sex = censusMember.Sym_Gender__c;
            ratingCensus.tier = censusMember.Sym_Tier__c;
            //ratingCensus.eligibility = censusMember.Sym_Eligibility__c;
            ratingCensus.eligibility = 'E';
            ratingRequest.census.add(ratingCensus);    
        }

        AnthemAPI.RatingResponse ratingResponse = AnthemAPI.getRatings(ratingRequest);

        if (ratingResponse.rateInfo != null && ratingResponse.rateInfo.size() > 0) {
            for (Integer i = 0; i < Math.min(Math.min(3, quote.QuoteLineItems.size()), ratingResponse.rateInfo.size()); i++) {
                QuoteLineItem quoteLineItem = quote.QuoteLineItems[i];
                AnthemAPI.RatingInfo ratingInfo = ratingResponse.rateInfo[i];
    
                quoteLineItem.UnitPrice = ratingInfo.single;
                quoteLineItem.Sym_Rate_Single_Number__c = ratingInfo.single;
                quoteLineItem.Sym_Rate_eeChildren__c = ratingInfo.eeChildren;
                quoteLineItem.Sym_Rate_Family__c = ratingInfo.family;
                quoteLineItem.Sym_Rate_Two_Party__c = ratingInfo.twoParty;
                quoteLineItem.Sym_MonthlyPremium__c = ratingInfo.monthlyPremium;
            }
    
            update quote.QuoteLineItems;

            quote.Symphony_Status__c = 'Plan Selection';
            update quote;
        }

    }
    
    private static AnthemAPI.RecommendationResponse getRecommendedPlans(Id quoteId) {
		Quote quote = [
            SELECT
            	Account.BillingPostalCode, Account.County__c, Account.SicDesc
            FROM
            	Quote
            WHERE
            	Id = :quoteId
        ];
		
        Sym_Census__c census = [
			SELECT
				Sym_Active_Member_Count__c, Sym_employeeChildrenPMPM__c, Sym_employeeSpousePMPM__c, Sym_Employee_with_dependents__c,
				Sym_familyPMPM__c, Sym_indvidualPMPM__c, Sym_Number_below_20__c, Sym_Number_Between_21_30__c, Sym_Number_between_31_40__c,
				Sym_Number_between_41_50__c, Sym_Number_between_51_60__c, Sym_Number_Employee_Spouse__c, Sym_Number_of_family_plans__c,
				Sym_Number_of_Female__c, Sym_Number_of_individual_plans__c, Sym_Number_of_Male__c, Sym_Number_over_60__c,
				Sym_Number_of_Plans__c, Sym_State__c, Sym_Total_Average_Age__c, Sym_Total_Dependents_Org__c, Sym_Total_Subscriber_Count_Org__c
			FROM
				Sym_Census__c
			WHERE
				Sym_Account__c = :quote.AccountId
			LIMIT
				1
		];

        Sym_Summary_of_Benefits__c eob = [
			SELECT
				Sym_Current_Coinsurance_INN__c, Sym_Current_Coinsurance_OON__c, Sym_Current_Family_Deductible_In_Network__c,
				Sym_Current_Family_Deductible_OON__c, Sym_Current_Individual_Deduct_In_Network__c,
				Sym_Current_Individual_Deductible_OON__c, Sym_Current_OOP_max_Family_INN__c, Sym_Current_OOP_max_Family_OON__c,
				Sym_Current_OOP_max_Individual_INN__c, Sym_Current_Rx_Tier_Four_Coinsurance__c, Sym_Current_Rx_Tier_Four_Copay__c,
				Sym_Current_Rx_Tier_One_Coinsurance__c, Sym_Current_Rx_Tier_One_Copay__c, Sym_Current_Rx_Tier_Three_Coinsurance__c,
				Sym_Current_Rx_Tier_Three_Copay__c, Sym_Current_Rx_Tier_Two_Coinsurance__c, Sym_Current_Rx_Tier_Two_Copay__c,
				Sym_Current_OOP_max_Individual_OON__c
			FROM
				Sym_Summary_of_Benefits__c
			WHERE
				Sym_Account__c = :quote.AccountId
			LIMIT
				1
		];

		Sym_Fine_Tune_Recommendation__c fineTune = [
			SELECT
				Sym_Family_In_Network_Deductible_Max__c, Sym_Fam_Out_Network_Deductible_Max__c,
				Sym_Indivdl_Ddtbl_InNet_Max__c, Sym_Indvl_Out_Network_Ddct_Max__c,
				Sym_Out_Network_Coinsurance_Maximum__c, Sym_In_Network_Coinsurance_Maximum__c,
				Sym_Family_Max_OoP_in_ntwrk_max__c, Sym_Family_Max_OoP_ot_ntwrk_max__c,
				Sym_Indvdl_Max_OoP_in_ntwrk_max__c, Sym_Indvdl_Max_OoP_ot_ntwrk_max__c,
				Sym_HMO_Medical_Plan__c, Sym_HSA_Medical_Plan__c, Sym_POS_Medical_Plan__c,
				Sym_PPO_Medical_Plan__c, Sym_Pharmacy_Tier_1_coinsur_max__c,
				Sym_Pharmacy_Tier_1_copay_max2__c, Sym_Pharmacy_Tier_2_coinsur_max__c,
				Sym_Pharmacy_Tier_2_copay_max__c, Sym_Pharmacy_Tier_3_coinsur_max__c,
				Sym_Pharmacy_Tier_3_copay_max__c, Sym_Pharmacy_Tier_4_coinsur_max__c,
				Sym_Pharmacy_Tier_4_copay_max__c        
			FROM
				Sym_Fine_Tune_Recommendation__c
			WHERE
				Sym_Account__c = :quote.AccountId
			LIMIT
				1
		];
        
        AnthemAPI.RecommendationRequest recommendationRequest = new AnthemAPI.RecommendationRequest();
        recommendationRequest.activeMemberCount = integerValue(census.Sym_Active_Member_Count__c);
        recommendationRequest.county = quote.Account.County__c;

        recommendationRequest.currentCoinsuranceINN = divideBy(eob.Sym_Current_Coinsurance_INN__c, 100);
        recommendationRequest.currentCoinsuranceOON = divideBy(eob.Sym_Current_Coinsurance_OON__c, 100);
        recommendationRequest.currentFamilyDeductibleINN = integerValue(eob.Sym_Current_Family_Deductible_In_Network__c);
        recommendationRequest.currentFamilyDeductibleOON = integerValue(eob.Sym_Current_Family_Deductible_OON__c);
        recommendationRequest.currentIndividualDeductibleINN = integerValue(eob.Sym_Current_Individual_Deduct_In_Network__c);
        recommendationRequest.currentIndividualDeductibleOON = integerValue(eob.Sym_Current_Individual_Deductible_OON__c);
        recommendationRequest.currentOOPmaxFamilyINN = integerValue(eob.Sym_Current_OOP_max_Family_INN__c);
        recommendationRequest.currentOOPmaxFamilyOON = integerValue(eob.Sym_Current_OOP_max_Family_OON__c);
        recommendationRequest.currentOOPmaxIndividualINN = integerValue(eob.Sym_Current_OOP_max_Individual_INN__c);
        recommendationRequest.currentOOPmaxIndividualOON = integerValue(eob.Sym_Current_OOP_max_Individual_OON__c);
        recommendationRequest.currentRxTierFourCoinsurance = divideBy(eob.Sym_Current_Rx_Tier_Four_Coinsurance__c, 100);
        recommendationRequest.currentRxTierFourCopay = integerValue(eob.Sym_Current_Rx_Tier_Four_Copay__c);
        recommendationRequest.currentRxTierOneCoinsurance = divideBy(eob.Sym_Current_Rx_Tier_One_Coinsurance__c, 100);
        recommendationRequest.currentRxTierOneCopay = integerValue(eob.Sym_Current_Rx_Tier_One_Copay__c);
        recommendationRequest.currentRxTierThreeCoinsurance = divideBy(eob.Sym_Current_Rx_Tier_Three_Coinsurance__c, 100);
        recommendationRequest.currentRxTierThreeCopay = integerValue(eob.Sym_Current_Rx_Tier_Three_Copay__c);
        recommendationRequest.currentRxTierTwoCoinsurance = divideBy(eob.Sym_Current_Rx_Tier_Two_Coinsurance__c, 100);
        recommendationRequest.currentRxTierTwoCopay = integerValue(eob.Sym_Current_Rx_Tier_Two_Copay__c);
        recommendationRequest.effectiveDt = '01/01/2020';
        recommendationRequest.employeeChildrenPMPM = census.Sym_employeeChildrenPMPM__c;
        recommendationRequest.employeeSpousePMPM = census.Sym_employeeSpousePMPM__c;
        recommendationRequest.familyPMPM = census.Sym_familyPMPM__c;
        recommendationRequest.indvidualPMPM = census.Sym_indvidualPMPM__c;

        if (fineTune.Sym_HMO_Medical_Plan__c) {
            recommendationRequest.memberSelectionCategory = 'HMO';
        } else if (fineTune.Sym_PPO_Medical_Plan__c) {
            recommendationRequest.memberSelectionCategory = 'PPO';
        } else if (fineTune.Sym_POS_Medical_Plan__c) {
            recommendationRequest.memberSelectionCategory = 'POS';
        } else if (fineTune.Sym_HSA_Medical_Plan__c) {
            recommendationRequest.memberSelectionCategory = 'HSA';
        }

        recommendationRequest.numberBelow20 = integerValue(census.Sym_Number_below_20__c);
        recommendationRequest.numberBetween21And30 = integerValue(census.Sym_Number_Between_21_30__c);
        recommendationRequest.numberBetween31And40 = integerValue(census.Sym_Number_between_31_40__c);
        recommendationRequest.numberBetween41And50 = integerValue(census.Sym_Number_between_41_50__c);
        recommendationRequest.numberBetween51And60 = integerValue(census.Sym_Number_between_51_60__c);
        recommendationRequest.numberEK = integerValue(census.Sym_Employee_with_dependents__c);
        recommendationRequest.numberES = integerValue(census.Sym_Number_Employee_Spouse__c);
        recommendationRequest.numberFamilyPlans = integerValue(census.Sym_Number_of_family_plans__c);
        recommendationRequest.numberFemale = integerValue(census.Sym_Number_of_Female__c);
        recommendationRequest.numberIndividualPlans = integerValue(census.Sym_Number_of_individual_plans__c);
        recommendationRequest.numberMale = integerValue(census.Sym_Number_of_Male__c);
        recommendationRequest.numberOver60 = integerValue(census.Sym_Number_over_60__c);
        recommendationRequest.numbOfPlans = integerValue(census.Sym_Number_of_Plans__c);
        //recommendationRequest.sicCd = integerValue(quote.Account.SicDesc.SubStringBefore(' '));
        //recommendationRequest.sicDivision = quote.Account.SicDesc.SubStringAfter(' ');
        recommendationRequest.sicCd = 8211;
        recommendationRequest.sicDivision = 'Services';

        recommendationRequest.stateCode = census.Sym_State__c;
        recommendationRequest.targetDeductibleFamilyINN = integerValue(fineTune.Sym_Family_In_Network_Deductible_Max__c);
        recommendationRequest.targetDeductibleFamilyOON = integerValue(fineTune.Sym_Fam_Out_Network_Deductible_Max__c);
        recommendationRequest.targetDeductibleIndividualINN = integerValue(fineTune.Sym_Indivdl_Ddtbl_InNet_Max__c);
        recommendationRequest.targetDeductibleIndividualOON = integerValue(fineTune.Sym_Indvl_Out_Network_Ddct_Max__c);
        recommendationRequest.targetINNCoinsurance = divideBy(fineTune.Sym_In_Network_Coinsurance_Maximum__c, 100);
        recommendationRequest.targetOONCoinsurance = divideBy(fineTune.Sym_Out_Network_Coinsurance_Maximum__c, 100);
        recommendationRequest.targetOOPMaxFamilyINN = integerValue(fineTune.Sym_Family_Max_OoP_in_ntwrk_max__c);
        recommendationRequest.targetOOPMaxFamilyOON = integerValue(fineTune.Sym_Family_Max_OoP_ot_ntwrk_max__c);
        recommendationRequest.targetOOPMaxIndividualINN = integerValue(fineTune.Sym_Indvdl_Max_OoP_in_ntwrk_max__c);
        recommendationRequest.targetOOPMaxIndividualOON = integerValue(fineTune.Sym_Indvdl_Max_OoP_ot_ntwrk_max__c);
        recommendationRequest.targetRxTierFourCoinsurance = divideBy(fineTune.Sym_Pharmacy_Tier_4_coinsur_max__c, 100);
        recommendationRequest.targetRxTierFourCopay = integerValue(fineTune.Sym_Pharmacy_Tier_4_copay_max__c);
        recommendationRequest.targetRxTierOneCoinsurance = divideBy(fineTune.Sym_Pharmacy_Tier_1_coinsur_max__c, 100);
        recommendationRequest.targetRxTierOneCopay = integerValue(fineTune.Sym_Pharmacy_Tier_1_copay_max2__c);
        recommendationRequest.targetRxTierThreeCoinsurance = divideBy(fineTune.Sym_Pharmacy_Tier_3_coinsur_max__c, 100);
        recommendationRequest.targetRxTierThreeCopay = integerValue(fineTune.Sym_Pharmacy_Tier_3_copay_max__c);
        recommendationRequest.targetRxTierTwoCoinsurance = divideBy(fineTune.Sym_Pharmacy_Tier_2_coinsur_max__c, 100);
        recommendationRequest.targetRxTierTwoCopay = integerValue(fineTune.Sym_Pharmacy_Tier_2_copay_max__c);
        recommendationRequest.totalAvgAge = integerValue(census.Sym_Total_Average_Age__c);
        recommendationRequest.totalDpndntOrg = integerValue(census.Sym_Total_Dependents_Org__c);
        recommendationRequest.totalSbscrbrCntOrg = integerValue(census.Sym_Total_Subscriber_Count_Org__c);
        recommendationRequest.zipCode = integerValue(quote.Account.BillingPostalCode);
        
        AnthemAPI.RecommendationResponse recommendationResponse = AnthemAPI.getRecommendations(recommendationRequest);
        
        return recommendationResponse;
    } 

  	public static Integer integerValue(Object value) {
		return (value == null ? null : Integer.valueOf(value));
	}

	public static Decimal divideBy(Decimal value, Decimal divisor) {
		return (value == null ? null : (value / divisor));
	}
    
    public static Decimal multiplyBy(Decimal value, Decimal multiplier) {
		return (value == null ? null : (value * multiplier));
	}
    
    public static Decimal multiplyGreaterThanZeroBy(Decimal value, Decimal multiplier) {
        if (value == null || value > 0) {
			return multiplyBy(value, multiplier);
        } else {
            return value;
        }
	}

	global class MemberInfo {

		global String firstName {get; set;}
		global String lastName {get; set;}
		global String dateOfBirth {get; set;}
		global String gender {get; set;}
		global String tier {get; set;}
		global String zipCode {get; set;}

	}

	global class FindPlansResponse {
        
        global String symphonyStatus {get; set;}
        
    }
    
    global class SymphonyPlan {

        global String id {get; set;}
        global String quoteId {get; set;}
        global Integer members {get; set;}
        global String funding {get; set;}
        global String financing {get; set;}

        
		global SymphonyPlan() {
		}

        global SymphonyPlan(QuoteLineItem quoteLineItem) {
            id = quoteLineItem.Id;
            quoteId = quoteLineItem.QuoteId;
            members = (quoteLineItem.Members__c == null ? null : quoteLineItem.Members__c.intValue());
            funding = quoteLineItem.Funding__c;
            financing = quoteLineItem.Financing__c;
        }

    } 
    
}