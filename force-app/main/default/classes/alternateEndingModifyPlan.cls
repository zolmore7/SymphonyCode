global with sharing class alternateEndingModifyPlan {    
    @AuraEnabled
    public static String getProductInfoFromFJA(String ContractCode, Id quoteLineItemId){
        System.debug('ContractCode:'+ContractCode);
        System.debug('quoteLineItemId:'+quoteLineItemId);
        HttpRequest req = new HttpRequest();
        
        final String url = 'http://159.203.107.214/pc/services/restapi/salesforce/get/plan/'+ContractCode;
        
        //Set HTTPRequest Method
        req.setMethod('GET');
        req.setEndPoint(url);
        req.setHeader('content-type', 'application/json');
        
        Http http = new Http();
        
        try {
            //Execute web service call here      
            HTTPResponse res = http.send(req);   
            
            //Helpful debug messages
            system.debug(res.toString());
            system.debug('STATUS:'+res.getStatus());
            system.debug('STATUS_CODE:'+res.getStatusCode());
            system.debug('RESPONSE BODY: ' + res.getBody());
            
            String strResponse = res.getBody();
            //passing the updated json string to JSON2Apex parse method
            QuoteLineItem qli = [Select id,ProductLOB__c,Sym_In_Network_Coinsurance__c,
                                 Sym_In_Network_Benefit_Plan_Max_Limit__c,Sym_Orthodontic_Coverage__c,
                                 Sym_Rate_Single_Number__c,Sym_Rate_Two_Party__c,Sym_Rate_eeChildren__c,
                                 Sym_Rate_Family__c from QuoteLineItem where id =:quoteLineItemId];
            Plan p = new Plan();
            p.planList = retrieveData(strResponse);
            QuoteLine ql = new QuoteLine();
            ql.Id = qli.Id;
            ql.ProductLOB = qli.ProductLOB__c;
            ql.InNetworkCoinsurance = qli.Sym_In_Network_Coinsurance__c;
            ql.InNetworkBenefitPlanMaxLimit = qli.Sym_In_Network_Benefit_Plan_Max_Limit__c;
            ql.OrthodonticCoverage = qli.Sym_Orthodontic_Coverage__c;
            ql.RateSingleNumber = qli.Sym_Rate_Single_Number__c;
            ql.RateTwoParty = qli.Sym_Rate_Two_Party__c;
            ql.RateChildren = qli.Sym_Rate_eeChildren__c;
            ql.RateFamily = qli.Sym_Rate_Family__c;
            p.QuoteLineItem = ql;
            return  JSON.serialize(p);
            
        } catch(System.CalloutException e) {
            System.debug('error calling service');
            throw new AuraHandledException('error invoking s&s service: ' + e.getMessage());
        }
    }
    
    public Static List<PlanValues> retrieveData(String strResponse) {
        List<PlanValues> returnValue = new List<PlanValues>();
        
        List<PlanValues> pvList = new List<PlanValues>();
        List<SYM_FJA_API_ModifyPlan_Json2Apex> jsonApex = SYM_FJA_API_ModifyPlan_Json2Apex.parse(strResponse);
        SYM_FJA_API_ModifyPlan_Json2Apex plan = jsonApex[0];
        List<SYM_FJA_API_ModifyPlan_Json2Apex.accumulators> accumulators = new List<SYM_FJA_API_ModifyPlan_Json2Apex.accumulators>();
        for(SYM_FJA_API_ModifyPlan_Json2Apex.AttachedPlans attachedPlan: plan.AttachedPlans){
            //if(attachedPlan.planHeader.networkVariation == 'INN'){
            accumulators = attachedPlan.accumulators;
            break;
            //}
        }
        if(accumulators.size() > 0){
            for(SYM_FJA_API_ModifyPlan_Json2Apex.accumulators accumulator: accumulators){
                System.debug('1');
                if(accumulator.accumulatorDisplayName == 'In Network Coinsurance'){
                    System.debug('2');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.value;
                    pv.Min = accumulator.domains.percentage.continuousEntries[0].min;
                    pv.Max = accumulator.domains.percentage.continuousEntries[0].max;
                    pv.Step = accumulator.domains.percentage.continuousEntries[0].increment;
                    pv.Name = 'In Network Coinsurance';
                    returnValue.add(pv);
                }
                if(accumulator.accumulatorDisplayName == 'In Network Individual Deductible'){
                    System.debug('4');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.indivMax;
                    pv.Min = accumulator.domains.IndivMax.continuousEntries[0].min;
                    pv.Max = accumulator.domains.IndivMax.continuousEntries[0].max;
                    pv.Step = accumulator.domains.IndivMax.continuousEntries[0].increment;
                    pv.Name = 'In Network Individual Deductible';
                    returnValue.add(pv);
                }
                if(accumulator.accumulatorDisplayName == 'In Network Family Deductible'){
                    System.debug('5');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.indivMax;
                    pv.Min = accumulator.domains.IndivMax.continuousEntries[0].min;
                    pv.Max = accumulator.domains.IndivMax.continuousEntries[0].max;
                    pv.Step = accumulator.domains.IndivMax.continuousEntries[0].increment;
                    pv.Name = 'In Network Family Deductible';
                    returnValue.add(pv);
                }
                if(accumulator.accumulatorDisplayName == 'In Network Out of Pocket Maximum Individual'){
                    System.debug('6');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.indivMax;
                    pv.Min = accumulator.domains.IndivMax.continuousEntries[0].min;
                    pv.Max = accumulator.domains.IndivMax.continuousEntries[0].max;
                    pv.Step = accumulator.domains.IndivMax.continuousEntries[0].increment;
                    pv.Name = 'In Network Out of Pocket Maximum Individual';
                    returnValue.add(pv);
                }
                if(accumulator.accumulatorDisplayName == 'In Network Out of Pocket Maximum Family'){
                    System.debug('7');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.indivMax;
                    pv.Min = accumulator.domains.IndivMax.continuousEntries[0].min;
                    pv.Max = accumulator.domains.IndivMax.continuousEntries[0].max;
                    pv.Step = accumulator.domains.IndivMax.continuousEntries[0].increment;
                    pv.Name = 'In Network Out of Pocket Maximum Family';
                    returnValue.add(pv);
                }
                if(accumulator.accumulatorDisplayName == 'In Network Benefit Plan Maximum Dental Dollar Limit'){
                    System.debug('8');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.indivMax;
                    pv.Min = accumulator.domains.IndivMax.continuousEntries[0].min;
                    pv.Max = accumulator.domains.IndivMax.continuousEntries[0].max;
                    pv.Step = accumulator.domains.IndivMax.continuousEntries[0].increment;
                    pv.Name = 'In Network Benefit Plan Maximum Dental Dollar Limit';
                    returnValue.add(pv);
                }
                if(accumulator.accumulatorDisplayName == 'In Network Diagnostic / Preventive Services Coinsurance'){
                    System.debug('9');
                    PlanValues pv = new PlanValues();
                    pv.DefaultValue = accumulator.value;
                    pv.Min = accumulator.domains.percentage.continuousEntries[0].min;
                    pv.Max = accumulator.domains.percentage.continuousEntries[0].max;
                    pv.Step = accumulator.domains.percentage.continuousEntries[0].increment;
                    pv.Name = 'In Network Diagnostic / Preventive Services Coinsurance';
                    returnValue.add(pv);
                }
            }
        }
        
        return returnValue;
    }
    
    @AuraEnabled
    public static void SaveQuoteLines(Id QuoteLineId,Double InNetworkIndividualDeductible,Double InNetworkFamilyDeductible,Double InNetworkOutofPocketMaximumIndividual,Double InNetworkOutofPocketMaximumFamily,Double InNetworkCoinsurance,Double UnitPrice){
        System.debug('SaveQuoteLines ccc:'+QuoteLineId);
        try{
            QuoteLineItem qli = [Select id, Sym_In_Network_Coinsurance__c,Sym_In_Network_Family_Deductible__c ,Sym_In_Network_Individual_Deductible__c ,Sym_In_Network_Out_of_Pocket_Max_Family__c ,Sym_In_Network_Out_of_Pocket_Max_Ind__c  from QuoteLineItem where id =:QuoteLineId For Update];
            qli.Sym_In_Network_Coinsurance__c = InNetworkCoinsurance;
            qli.Sym_In_Network_Family_Deductible__c = InNetworkFamilyDeductible;
            qli.Sym_In_Network_Individual_Deductible__c = InNetworkIndividualDeductible;
            qli.Sym_In_Network_Out_of_Pocket_Max_Family__c = InNetworkOutofPocketMaximumFamily;
            qli.Sym_In_Network_Out_of_Pocket_Max_Ind__c = InNetworkOutofPocketMaximumIndividual;
            qli.UnitPrice = UnitPrice;
            Update qli;
        }catch(Exception ex){
            throw new AuraHandledException('Error Saving Cost Share Changes : '+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void SaveQuoteLinesDental(Id QuoteLineId,Double InNetworkCoinsurance, Double InNetworkBenefitPlanMaxLimit, String OrthodonticCoverage,String QL,Double UnitPrice){
        System.debug('InNetworkBenefitPlanMaxLimit ccc:'+InNetworkBenefitPlanMaxLimit);
        System.debug('InNetworkCoinsurance ccc:'+InNetworkCoinsurance);
        System.debug('OrthodonticCoverage ccc:'+OrthodonticCoverage);
        System.debug('SaveQuoteLines ccc:'+QuoteLineId);
        System.debug('QL ccc:'+QL);
        Map<String,Object> qlMap = (Map<String,Object>)JSON.deserializeUntyped(QL);
        try{
            QuoteLineItem qli = [Select id, Sym_In_Network_Coinsurance__c,Sym_In_Network_Benefit_Plan_Max_Limit__c,Sym_Orthodontic_Coverage__c from QuoteLineItem where id =:QuoteLineId For Update];
            qli.Sym_In_Network_Coinsurance__c = InNetworkCoinsurance;
            qli.Sym_In_Network_Benefit_Plan_Max_Limit__c = InNetworkBenefitPlanMaxLimit;
            qli.Sym_Orthodontic_Coverage__c = OrthodonticCoverage;
            qli.Sym_Rate_Single_Number__c = (Decimal)qlMap.get('RateSingleNumber');
            qli.Sym_Rate_Two_Party__c = (Decimal)qlMap.get('RateTwoParty');
            qli.Sym_Rate_eeChildren__c = (Decimal)qlMap.get('RateChildren');
            qli.Sym_Rate_Family__c = (Decimal)qlMap.get('RateFamily');
            //qli.UnitPrice = UnitPrice;
            Update qli;
        }catch(Exception ex){
            throw new AuraHandledException('Error Saving Cost Share Changes : '+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getRates(Id quoteLineItemId, Double InNetworkCoinsurance, Double InNetworkIndividualDeductible, Double InNetworkOutofPocketMaximumIndividual) {
        AnthemAPI.MedicalCostShare mcs = new AnthemAPI.MedicalCostShare();
        mcs.innDeductible = InNetworkIndividualDeductible;
        mcs.oopMax = InNetworkOutofPocketMaximumIndividual;
        if(InNetworkCoinsurance != null && InNetworkCoinsurance > 1){
            mcs.innCoinsurance = InNetworkCoinsurance/100;
        }else{
            mcs.innCoinsurance = InNetworkCoinsurance;
        }
        return getRatesAPICall(quoteLineItemId, mcs, null);
    }
    
    @AuraEnabled
    public static String getRatesDental(Id quoteLineItemId, String InNetworkCoinsurance, String InNetworkBenefitPlanMaxLimit, String OrthodonticCoverage) {
        AnthemAPI.DentalCostShare dcs = new AnthemAPI.DentalCostShare();
        dcs.diagnosticAndPreventive = InNetworkCoinsurance+'%';
        //if(InNetworkCoinsurance != null && Integer.valueof(InNetworkCoinsurance) > 1){
        //dcs.diagnosticAndPreventive = Integer.valueof(InNetworkCoinsurance)/100;
        //}else{
        //    dcs.diagnosticAndPreventive = InNetworkCoinsurance;
        //}
        dcs.innAnnualMax = InNetworkBenefitPlanMaxLimit;
        dcs.orthodonticCoverage = OrthodonticCoverage;
        return getRatesAPICall(quoteLineItemId, null, dcs);
    }
    
    public static String getRatesAPICall(Id quoteLineItemId, AnthemAPI.MedicalCostShare mcs , AnthemAPI.DentalCostShare dcs) {
        try{
            System.debug('In getRatesAPICall');
            RateValues rv = new RateValues();
            QuoteLineItem qli = [SELECT 
                                 Quote.Opportunity.Account.Name,quote.Opportunity.Id,quote.Id,
                                 Product2.Name, Product2.sym_Symphony_Product_Id__c, Product2.ProductCode, 
                                 Product2.Contract_Code__c, Product2.LG_Network__c, LineNumber 
                                 FROM QuoteLineItem where id = :quoteLineItemId];
            
            List<Sym_Census_Member__c> censusMembers = [
                SELECT 
                Sym_First_Name__c, Sym_Last_Name__c, Sym_Birthday_Text__c, Sym_Zip_Code__c, Sym_Gender__c, Sym_Tier__c, Sym_Eligibility__c
                FROM
                Sym_Census_Member__c
                WHERE
                Sym_Census__r.Sym_Account__c = :qli.quote.Opportunity.AccountId
            ];
            System.debug('Assign RatingRequest');
            AnthemAPI.RatingRequest ratingRequest = new AnthemAPI.RatingRequest();
            AnthemApi.RatingPlan ratingPlan = new AnthemApi.RatingPlan();
            //ratingPlan.cdhpIndicator = 'HSA';
            if(mcs != null){
                ratingRequest.groupName = qli.quote.Opportunity.Account.Name;
                ratingRequest.opportunityID = qli.quote.Opportunity.Id;
                ratingRequest.quoteHeaderID = qli.quote.Id;
                ratingRequest.sicCode = 3999;
                ratingRequest.state = 'OH';
                ratingRequest.companyZip = 43085;
                ratingRequest.groupSize = new AnthemAPI.GroupSize();
                ratingRequest.groupSize.maximum = 250;
                ratingRequest.groupSize.minimum = 51;
                ratingRequest.effectiveDate = '2020-04-01';
                //ratingRequest.customerType = 'Prospect';
                ratingRequest.inputTier = 4;
                ratingRequest.outputTier = 4;
                ratingRequest.commissionValue = 20;
                ratingRequest.commissionType = 'PCPM';
                ratingRequest.chamberOfCommerce = 'NO';
                ratingRequest.participationRate = 0.7;
                ratingRequest.premiumDelay = 30;
                ratingRequest.ratingRequestPlans = new List<AnthemAPI.RatingPlan>();
                ratingRequest.census = new List<AnthemAPI.RatingCensus>();
                System.debug('Assign RatingPlan');
                ratingPlan.quoteLineItemID = qli.LineNumber;
                ratingPlan.fundingType = 'FI';
                ratingPlan.productID = Integer.valueOf(qli.Product2.sym_Symphony_Product_Id__c);
                ratingPlan.planConstruct = 'CUSTOM';
                ratingPlan.contractCode = qli.Product2.Contract_Code__c;           
                ratingPlan.networkName = 'Blue Access';
                ratingPlan.networkType = 'PPO';
                ratingPlan.planName = qli.Product2.Name;
                ratingPlan.lob = 'Medical';
                ratingPlan.medicalCostShare = mcs;
            }
            if(dcs != null){
                ratingRequest.groupName = qli.quote.Opportunity.Account.Name;
                ratingRequest.opportunityID = qli.quote.Opportunity.Id;
                ratingRequest.quoteHeaderID = qli.quote.Id;
                ratingRequest.sicCode = 1021;
                ratingRequest.state = 'OH';
                ratingRequest.companyZip = 43010;
                ratingRequest.groupSize = new AnthemAPI.GroupSize();
                ratingRequest.groupSize.maximum = 180;
                ratingRequest.groupSize.minimum = 120;
                ratingRequest.effectiveDate = '2020-01-01';
                ratingRequest.customerType = 'Prospect';
                ratingRequest.inputTier = 4;
                ratingRequest.outputTier = 4;
                ratingRequest.commissionValue = 0;
                ratingRequest.commissionType = '';
                ratingRequest.chamberOfCommerce = 'NO';
                ratingRequest.participationRate = 0.7;
                ratingRequest.premiumDelay = 90;
                ratingRequest.ratingRequestPlans = new List<AnthemAPI.RatingPlan>();
                ratingRequest.census = new List<AnthemAPI.RatingCensus>();
                System.debug('Assign RatingPlan');
                
                ratingPlan.quoteLineItemID = qli.LineNumber;
                //ratingPlan.fundingType = 'FI';
                //ratingPlan.productID = Integer.valueOf(qli.Product2.sym_Symphony_Product_Id__c);
                //ratingPlan.planConstruct = 'CUSTOM';
                //ratingPlan.contractCode = qli.Product2.Contract_Code__c;           
                //ratingPlan.networkName = 'Blue Access';
                //ratingPlan.networkType = 'PPO';
                ratingPlan.planName = qli.Product2.Name;
                System.debug('Assign Dental');
                ratingPlan.lob = 'Dental';
                ratingPlan.DentalCostShare = dcs;
                System.debug('Assign Dental Done');
            }
            ratingRequest.ratingRequestPlans.add(ratingPlan);
            
            for (Sym_Census_Member__c censusMember : censusMembers) {
                AnthemAPI.RatingCensus ratingCensus = new AnthemAPI.RatingCensus();
                ratingCensus.firstName = censusMember.Sym_First_Name__c;
                ratingCensus.lastName = censusMember.Sym_Last_Name__c;
                //Patch to fix birthday format wrong
                String formattedBirthday = '';
                List<String> thePieces = censusMember.Sym_Birthday_Text__c.split('/');
                formattedBirthday = '19' + thePieces[2] + '-' + thePieces[0] + '-' + thePieces[1];
                ratingCensus.dateOfBirth = formattedBirthday;
                ratingCensus.sex = censusMember.Sym_Gender__c;
                ratingCensus.tier = censusMember.Sym_Tier__c;
                ratingCensus.zip = Integer.valueOf(censusMember.Sym_Zip_Code__c);
                ratingCensus.eligibility = 'E';
                ratingRequest.census.add(ratingCensus);    
            }
            System.debug('before ratingResponse xyz::'+ratingRequest);
            AnthemAPI.RatingResponse ratingResponse = AnthemAPI.getRatings(ratingRequest);
            System.debug('ratingResponse xyz::'+ratingResponse);
            if (ratingResponse.rateInfo != null && ratingResponse.rateInfo.size() > 0) {
                AnthemAPI.RatingInfo ratingInfo = ratingResponse.rateInfo[0];
                rv.Single = ratingInfo.single;
                rv.Children = ratingInfo.eeChildren;
                rv.Family = ratingInfo.family;
                rv.TwoParty = ratingInfo.twoParty;
                rv.MonthlyPremium = ratingInfo.monthlyPremium;
            }
            return JSON.serialize(rv);
        }catch(Exception ex){
            throw new AuraHandledException('Error Getting Rates : '+ex.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static Map<String, Object> getNewContractCode(Map<String, Object> plan) {
        HttpRequest req = new HttpRequest();
        String url = 'http://159.203.107.214/pc/services/restapi/salesforce/create/package';
        system.debug('createPlan: endpoint: ' + url);
        
        String jsonString = JSON.serialize(plan);
        system.debug('Plan JSON sent: ');
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndPoint(url);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonString);
        req.setCompressed(true);
        
        Http http = new Http();
        
        try {
            //Execute web service call here      
            HTTPResponse res = http.send(req);
            
            //Helpful debug messages
            system.debug('createPlan: Response is ' + res.toString());
            
            //printHeaders(res);
            
            if (res.getStatusCode() != 201 && res.getStatusCode() != 200) {
                system.debug('Response body: ' + res.getBody());
                throw new AuraHandledException('Could not create plan. Received http code: ' + res.getStatusCode());
            }
            
            //Will contain 'planName' and 'planId'
            Map<String, Object> result = (Map<String, Object> ) JSON.deserializeUntyped(res.getBody());
            
            //All the location
            result.put('directURL', res.getHeader('Location'));
            system.debug('Data from response: ' + result);
            
            return result;
        } catch (System.CalloutException e) {
            System.debug('createPlan: error calling service');
            throw new AuraHandledException('error invoking s&s service: ' + e.getMessage());
        }
    }
    global class Plan{
        global List<PlanValues> planList {get;set;}
        global QuoteLine QuoteLineItem {get;set;}
    }
    
    global class PlanValues{
        global String Name {get;set;}
        global double DefaultValue {get;set;}
        global double Min {get;set;}
        global double Max {get;set;}
        global double Step {get;set;}
    }
    
    global class RateValues{
        global double Single {get;set;}
        global double Children {get;set;}
        global double Family {get;set;}
        global double TwoParty {get;set;}
        global double MonthlyPremium {get;set;}
    }
    
    global class QuoteLine{
        global String ProductLOB {get;set;}
        global Id Id {get;set;}
        global double InNetworkCoinsurance {get;set;}
        global double InNetworkBenefitPlanMaxLimit {get;set;}
        global String OrthodonticCoverage {get;set;}
        global double RateSingleNumber {get;set;}
        global double RateTwoParty {get;set;}
        global double RateChildren {get;set;}
        global double RateFamily {get;set;}
    }
    
}