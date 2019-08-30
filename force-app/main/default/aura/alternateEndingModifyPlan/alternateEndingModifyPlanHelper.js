({
    getContractDetails : function(component,event,ContractCode) {
        var action = component.get("c.getProductInfoFromFJA");
        action.setParams({
            "ContractCode": ContractCode,
            "quoteLineItemId": component.get("v.currentQuoteLineId")
        });
        action.setCallback(this, function(response) {
            var allValues = JSON.parse(response.getReturnValue());
            if (response.getState() == "SUCCESS") {
                console.log('Output::');
                console.log(allValues);
                component.set("v.Details",allValues.planList); 
                component.set("v.QuoteLine",allValues.QuoteLineItem);
                console.log(allValues.QuoteLineItem);
                this.hideSpinner(component);
            }else if (response.getState() === "ERROR") {
                component.set("v.Details",allValues);
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    parseDetails : function(component,event) {
        var error = false;
        var InNetworkIndividualDeductible = 0;
        var InNetworkFamilyDeductible = 0;
        var InNetworkOutofPocketMaximumIndividual = 0;
        var InNetworkOutofPocketMaximumFamily = 0;
        var InNetworkCoinsurance = 0;
        var InNetworkDiagnosticPreventiveServicesCoinsurance = 0;
        var InNetworkBenefitPlanMaximumDentalDollarLimit = 0;
        var detaillist = [];
        detaillist = component.get("v.Details");
        if(component.get("v.QuoteLine").ProductLOB == 'Medical'){
            if(component.find('INID').reportValidity() 
               && component.find('INFD').reportValidity()
               && component.find('INOOPMI').reportValidity()
               && component.find('INOOPMF').reportValidity()
               && component.find('INC').reportValidity()
              ){
                for (var i=0; i< detaillist.length; i++)
                {
                    if(detaillist[i].Name == 'In Network Individual Deductible'){
                        InNetworkIndividualDeductible = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Family Deductible'){
                        InNetworkFamilyDeductible = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Out of Pocket Maximum Individual'){
                        InNetworkOutofPocketMaximumIndividual = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Out of Pocket Maximum Family'){
                        InNetworkOutofPocketMaximumFamily = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Coinsurance'){
                        InNetworkCoinsurance = detaillist[i].DefaultValue;
                    }
                }
                this.saveQuoteLineItem(component,event,InNetworkIndividualDeductible,InNetworkFamilyDeductible,InNetworkOutofPocketMaximumIndividual,InNetworkOutofPocketMaximumFamily,InNetworkCoinsurance);
                
            }else{
                this.showToast(component,event,'Error','Please correct below errors before saving changes', 'error');
                this.hideSpinner(component);
            }
        }
        if(component.get("v.QuoteLine").ProductLOB == 'Dental'){
            if(component.find('INDPSC').reportValidity()
               && component.find('INBPMDDL').reportValidity()
              ){
                for (var i=0; i< detaillist.length; i++)
                {
                    if(detaillist[i].Name == 'In Network Diagnostic / Preventive Services Coinsurance'){
                        InNetworkDiagnosticPreventiveServicesCoinsurance = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Benefit Plan Maximum Dental Dollar Limit'){
                        InNetworkBenefitPlanMaximumDentalDollarLimit = detaillist[i].DefaultValue;
                    }
                }
                var OrthodonticCoverage = component.get("v.QuoteLine.OrthodonticCoverage");
                console.log(InNetworkDiagnosticPreventiveServicesCoinsurance+'/'+InNetworkBenefitPlanMaximumDentalDollarLimit);
                this.saveQuoteLineItemDental(component,event,InNetworkDiagnosticPreventiveServicesCoinsurance,InNetworkBenefitPlanMaximumDentalDollarLimit,OrthodonticCoverage);
                
            }else{
                this.showToast(component,event,'Error','Please correct below errors before saving changes', 'error');
                this.hideSpinner(component);
            }
        }
    },
    saveQuoteLineItem : function(component,event,InNetworkIndividualDeductible,InNetworkFamilyDeductible,InNetworkOutofPocketMaximumIndividual,InNetworkOutofPocketMaximumFamily,InNetworkCoinsurance) {
        var action = component.get("c.SaveQuoteLines");
        action.setParams({
            "QuoteLineId": component.get("v.currentQuoteLineId"),
            "InNetworkIndividualDeductible": InNetworkIndividualDeductible,
            "InNetworkFamilyDeductible": InNetworkFamilyDeductible,
            "InNetworkOutofPocketMaximumIndividual": InNetworkOutofPocketMaximumIndividual,
            "InNetworkOutofPocketMaximumFamily": InNetworkOutofPocketMaximumFamily,
            "InNetworkCoinsurance": InNetworkCoinsurance,
            "UnitPrice": component.get("v.currentPrice")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log('Success');
                this.showToast(component,event,'Success','Saved Cost Share Changes Successfully', 'success');
                this.hideSpinner(component);
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                var error = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        error = errors[0].message;
                    }
                }
                this.showToast(component,event,'Error',error, 'error');
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveQuoteLineItemDental : function(component,event,InNetworkCoinsurance,InNetworkBenefitPlanMaxLimit,OrthodonticCoverage) {
        var action = component.get("c.SaveQuoteLinesDental");
        action.setParams({
            "QuoteLineId": component.get("v.currentQuoteLineId"),
            "InNetworkCoinsurance": InNetworkCoinsurance,
            "InNetworkBenefitPlanMaxLimit": InNetworkBenefitPlanMaxLimit,
            "OrthodonticCoverage": OrthodonticCoverage,
            "UnitPrice": component.get("v.currentPrice")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log('Success');
                this.showToast(component,event,'Success','Saved Cost Share Changes Successfully', 'success');
                this.hideSpinner(component);
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                var error = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        error = errors[0].message;
                    }
                }
                this.showToast(component,event,'Error',error, 'error');
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component,event,title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    parsePriceDetails : function(component,event) {
        var InNetworkIndividualDeductible = 0;
        var InNetworkOutofPocketMaximumIndividual = 0;
        var InNetworkCoinsurance = 0;
        var InNetworkBenefitPlanMaximumDentalDollarLimit = 0;
        var InNetworkDiagnosticPreventiveServicesCoinsurance = 0;
        var detaillist = [];
        detaillist = component.get("v.Details");
        if(component.get("v.QuoteLine").ProductLOB == 'Medical'){
            console.log(component.find('INID').reportValidity());
            console.log(component.find('INFD').reportValidity());
            console.log(component.find('INOOPMI').reportValidity());
            console.log(component.find('INOOPMF').reportValidity());
            console.log(component.find('INC').reportValidity());
            if(component.find('INID').reportValidity() 
               && component.find('INFD').reportValidity()
               && component.find('INOOPMI').reportValidity()
               && component.find('INOOPMF').reportValidity()
               && component.find('INC').reportValidity()
              ){
                for (var i=0; i< detaillist.length; i++)
                {
                    if(detaillist[i].Name == 'In Network Individual Deductible'){
                        InNetworkIndividualDeductible = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Out of Pocket Maximum Individual'){
                        InNetworkOutofPocketMaximumIndividual = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Coinsurance'){
                        InNetworkCoinsurance = detaillist[i].DefaultValue;
                    }
                }
                this.getCalculatedPrice(component,event,InNetworkIndividualDeductible,InNetworkOutofPocketMaximumIndividual,InNetworkCoinsurance);
            }else{
                this.showToast(component,event,'Error','Please correct below errors before getting Price', 'error');
                this.hideSpinner(component);
            }
        }
        if(component.get("v.QuoteLine").ProductLOB == 'Dental'){
            if(component.find('INDPSC').reportValidity()
               && component.find('INBPMDDL').reportValidity()
              ){
                for (var i=0; i< detaillist.length; i++)
                {
                    if(detaillist[i].Name == 'In Network Diagnostic / Preventive Services Coinsurance'){
                        InNetworkDiagnosticPreventiveServicesCoinsurance = detaillist[i].DefaultValue;
                    }else if(detaillist[i].Name == 'In Network Benefit Plan Maximum Dental Dollar Limit'){
                        InNetworkBenefitPlanMaximumDentalDollarLimit = detaillist[i].DefaultValue;
                    }
                }
                var OrthodonticCoverage = component.get("v.QuoteLine.OrthodonticCoverage");
                
                this.getCalculatedPriceDental(component,event,InNetworkDiagnosticPreventiveServicesCoinsurance,InNetworkBenefitPlanMaximumDentalDollarLimit,OrthodonticCoverage);
            }else{
                this.showToast(component,event,'Error','Please correct below errors before getting Price', 'error');
                this.hideSpinner(component);
            }
        }
    },
    getCalculatedPrice : function(component,event,InNetworkIndividualDeductible,InNetworkOutofPocketMaximumIndividual,InNetworkCoinsurance) {
        var action = component.get("c.getRates");
        action.setParams({
            "quoteLineItemId": component.get("v.currentQuoteLineId"),
            "InNetworkIndividualDeductible": InNetworkIndividualDeductible,
            "InNetworkOutofPocketMaximumIndividual": InNetworkOutofPocketMaximumIndividual,
            "InNetworkCoinsurance": InNetworkCoinsurance
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log('Success');
                this.showToast(component,event,'Success','Got Calculated Price Successfully', 'success');
                console.log(response.getReturnValue());
                var allValues = JSON.parse(response.getReturnValue());
                component.set("v.currentPrice",allValues.Single);
                this.hideSpinner(component);
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                var error = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        error = errors[0].message;
                    }
                }
                this.showToast(component,event,'Error',error, 'error');
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCalculatedPriceDental : function(component,event,InNetworkDiagnosticPreventiveServicesCoinsurance,InNetworkBenefitPlanMaximumDentalDollarLimit,OrthodonticCoverage) {
        var action = component.get("c.getRatesDental");
        action.setParams({
            "quoteLineItemId": component.get("v.currentQuoteLineId"),
            "InNetworkCoinsurance": InNetworkDiagnosticPreventiveServicesCoinsurance,
            "InNetworkBenefitPlanMaxLimit": InNetworkBenefitPlanMaximumDentalDollarLimit,
            "OrthodonticCoverage": OrthodonticCoverage
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log('Success');
                this.showToast(component,event,'Success','Got Calculated Price Successfully', 'success');
                console.log(response.getReturnValue());
                var allValues = JSON.parse(response.getReturnValue());
                component.set("v.currentPrice",allValues.Single);
                this.hideSpinner(component);
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                var error = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        error = errors[0].message;
                    }
                }
                this.showToast(component,event,'Error',error, 'error');
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateToQuote : function(component,event){
        // it returns only first value of Id
        //var AcctId = component.get("v.oppty").AccountId;
        
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": "0Q019000000L80MCAS",
            "slideDevName": "related"
        });
        sObectEvent.fire(); 
    },
    
    redirectToPreviousPage: function (component,event){
        $A.get('e.force:refreshView').fire();
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    },
    
    showSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})