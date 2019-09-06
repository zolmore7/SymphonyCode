public with sharing class SymphonyCallBrokerPortal {
    public SymphonyCallBrokerPortal() {

    }
    @future(callout=true)
    public static void sendMessageToPortal(List<String> payload) {
        system.debug('Passed=' + payload[0]);

        List<String> theFields = payload[0].split('\\|');
        
        String thePayload = '{"eventName": "' + theFields[0] + '","eventData": {"caseStage": "' + theFields[1] + '",	"completedDate": "' + DateTime.now()  + '"},"eventCorrelation": {	"correlationId": "' + theFields[3] + '",	"ein": "9999999",	"vendorAppId": "' + theFields[2] + '",	"vendorTransId": "3062c8f45hgdfghfdgh811f0e91027643e0"}}';
        
        LGJira2TokenDetail tokenDetail = new LGJiraUtility().AccessToken();

		Jira_EndPoint_Setting__mdt jireEndPointSetting = [
            SELECT
            	ApiKey__c
			FROM
            	Jira_EndPoint_Setting__mdt
            WHERE
            	IsSandbox__c = true
            LIMIT
            	1
        ];
        
        Anthem_API_Settings__c anthemAPISettings = Anthem_API_Settings__c.getOrgDefaults();

        System.debug('### API KEY=' + jireEndPointSetting.ApiKey__c);

        String endpoint = anthemAPISettings.Broker_Portal_Endpoint__c;
        String authorization = 'Bearer ' + tokenDetail.access_token;
        String apiKey = jireEndPointSetting.ApiKey__c;
        String body = thePayload;

        System.debug('### REQUEST EDNPOINT=' + endpoint);
        System.debug('### REQUEST BODY=' + body);

        HttpRequest httpRequest = new HttpRequest();
		httpRequest.setTimeout(60 * 1000);
		httpRequest.setEndpoint(endpoint);
		httpRequest.setMethod('POST');
		httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', authorization);
        httpRequest.setHeader('apikey', apiKey);

        if (String.isNotBlank(anthemAPISettings.Source_Environment__c)) {
            httpRequest.setHeader('meta-src-envrmt', anthemAPISettings.Source_Environment__c);
        }

		httpRequest.setBody(body);

        HttpResponse httpResponse = new Http().send(httpRequest);

        System.debug('### RESPONSE STATUS CODE=' + httpResponse.getStatusCode());
        System.debug('### RESPONSE BODY=' + httpResponse.getBody());

    }
}