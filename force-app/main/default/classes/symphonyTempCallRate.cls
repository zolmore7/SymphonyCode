public with sharing class symphonyTempCallRate {
    @InvocableMethod(label='Get Account Names')
    public static List<String> symphonyGetRate(List<Id> quoteId) {
        Quote quote = [Select Id, Opportunity.Id, Opportunity.Account.SicDesc, Opportunity.Account.BillingPostalCode, Opportunity.Account.Name FROM Quote WHERE Id = :quoteId LIMIT 1];

        AnthemAPI.RatingRequest ratingRequest = new AnthemAPI.RatingRequest();
        ratingRequest.groupName = quote.Opportunity.Account.Name;
        ratingRequest.opportunityID = quote.opportunity.Id;
        ratingRequest.quoteHeaderID = quote.Id;
        ratingRequest.sicCode = Integer.ValueOf(quote.Opportunity.Account.SicDesc.split(' ')[0]);
        ratingRequest.state = 'OH';
        ratingRequest.companyZip = Integer.ValueOf(quote.Opportunity.Account.BillingPostalCode);
        ratingRequest.groupSize = new AnthemAPI.GroupSize();
        ratingRequest.groupSize.maximum = 250;
        ratingRequest.groupSize.minimum = 51;
        ratingRequest.effectiveDate = '2020-01-01';
        //ratingRequest.lob = 'Medical';
        ratingRequest.customerType = 'Prospect';
        ratingRequest.inputTier = 4;
        ratingRequest.outputTier = 4;
        ratingRequest.commissionValue = 0;
        ratingRequest.commissionType = '';
        ratingRequest.chamberOfCommerce = 'NO';
        ratingRequest.participationRate = 0.5;
        ratingRequest.premiumDelay = 30;
        ratingRequest.ratingRequestPlans = new List<AnthemAPI.RatingPlan>();
        //ratingRequest.ratingRequestPlans.add(new AnthemAPI.RatingPlan());

        List <QuoteLineItem> allqli = [SELECT Id, Product2.Name, Product2.sym_Symphony_Product_Id__c, Product2.Id, Product2.ProductCode, Product2.Contract_Code__c, Product2.LG_Network__c FROM QuoteLineItem Where QuoteID = :quoteId[0]];
        Integer x = 0;
        for(QuoteLineItem qli : allqli) {
            AnthemApi.RatingPlan rrp = new AnthemApi.RatingPlan();
            //rrp.quoteLineItemID = qli.Id;
            //rrp.quoteLineItemID = 'xxxx1223';
            rrp.quoteLineItemID = qli.Id;
            rrp.fundingType = 'FI';
            rrp.lob = 'Medical';
            rrp.planName = qli.Product2.Name;
            //if(qli.Product2.Contract_Code__c == '51RX') {
            //    rrp.productID = Integer.valueOf('42459');
            //    system.debug('Prod Id=' + rrp.productID);
            //    rrp.contractCode = '50BN';
            //    system.debug(rrp.contractCode);                
            //} else if(qli.Product2.Contract_Code__c == '51QR') {
            //    rrp.productID = Integer.valueOf('42447');
            //    system.debug('Prod Id=' + rrp.productID);
            //    rrp.contractCode = '50L1';
            //    system.debug(rrp.contractCode);
            //} else if(qli.Product2.Contract_Code__c == '51PF') {
            //    rrp.productID = Integer.valueOf('42454');
            //    system.debug('Prod Id=' + rrp.productID);
            //    rrp.contractCode = '50MA';
            //    system.debug(rrp.contractCode);
            //} else {
                rrp.productID = Integer.valueOf(qli.Product2.sym_Symphony_Product_Id__c);
                system.debug('Prod Id=' + rrp.productID);
                rrp.contractCode = qli.Product2.Contract_Code__c;
                system.debug(rrp.contractCode);                
            //}
            rrp.networkName = 'Blue Access';
            rrp.networkType = 'PPO';
            //rrp.cdhpIndicator = 'HSA';
            rrp.cdhpIndicator = '';
            ratingRequest.ratingRequestPlans.add(rrp);
        }

        List<Sym_Census_Member__c> cmr = [SELECT ID, Sym_First_Name__c, Sym_Last_Name__c, Sym_Birthday_Text__c, Sym_Zip_Code__c, Sym_Gender__c, Sym_Tier__c, Sym_Eligibility__c FROM Sym_Census_Member__c WHERE Sym_Census__c = 'aA72f0000004FgOCAU'];
        ratingRequest.census = new List<AnthemAPI.RatingCensus>();
        for(Sym_Census_Member__c cm : cmr) {
            AnthemAPI.RatingCensus rrc = new AnthemAPI.RatingCensus();
            rrc.firstName = cm.Sym_First_Name__c;
            rrc.lastName = cm.Sym_Last_Name__c;
            
            //rrc.dateOfBirth = cm.Sym_Birthday_Text__c;
            //Patch to fix birthday format wrong
            String formattedBirthday = '';
            List<String> thePieces = cm.Sym_Birthday_Text__c.split('/');
            formattedBirthday = '19' + thePieces[2] + '-' + thePieces[0] + '-' + thePieces[1];
            rrc.dateOfBirth = formattedBirthday;


            rrc.zip = Integer.valueOf(cm.Sym_Zip_Code__c);
            rrc.sex = cm.Sym_Gender__c;
            rrc.tier = cm.Sym_Tier__c;
            //rrc.eligibility = cm.Sym_Eligibility__c;
            rrc.eligibility = 'E';
            ratingRequest.census.add(rrc);    
        }
        system.debug('### request=' + ratingRequest);
        AnthemAPI.RatingResponse ratingResponse = AnthemAPI.getRatings(ratingRequest);
        
               
        for(Integer y=0; y< ratingResponse.rateInfo.size() ; y++) {
            allqli[y].UnitPrice = ratingResponse.rateInfo[y].single;
            allqli[y].Sym_Rate_Single_Number__c = ratingResponse.rateInfo[y].single;
            allqli[y].Sym_Rate_eeChildren__c = ratingResponse.rateInfo[y].eeChildren;
            allqli[y].Sym_Rate_Family__c = ratingResponse.rateInfo[y].family;
            allqli[y].Sym_Rate_Two_Party__c = ratingResponse.rateInfo[y].twoParty;
            allqli[y].Sym_MonthlyPremium__c = ratingResponse.rateInfo[y].monthlyPremium;
        }


        update allqli; 

        quote.Symphony_Status__c = 'Plan Selection';
        update quote;
        
        List<String> temp = new List<String>();
        temp.add(ratingResponse.toString());
        return temp;
    }
}