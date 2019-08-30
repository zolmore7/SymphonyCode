({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);
        component.set("v.Details",null);
        var mypageRef = component.get("v.pageReference");
        component.set("v.currentContractCode",mypageRef.state.c__currentContractCode);
        component.set("v.currentQuoteLineId",mypageRef.state.c__currentQuoteLineId);
        console.log('Iddd:'+mypageRef.state.c__currentQuoteLineId);
        component.set("v.currentPrice",mypageRef.state.c__currentPrice);
        console.log('DOINTI'+mypageRef.state.c__currentContractCode);
        var ContractCode = mypageRef.state.c__currentContractCode;
        helper.getContractDetails(component,event,ContractCode);
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    goBackToQuote : function(component, event, helper) {
        helper.redirectToPreviousPage(component,event);
    },
    saveQuoteLine : function(component, event, helper) {
        helper.showSpinner(component);
        helper.parseDetails(component,event);
    },
    getPrice : function(component, event, helper) {
        helper.showSpinner(component);
        helper.parsePriceDetails(component,event);
    },
})