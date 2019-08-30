/*
 * Symphony Broker API
 * 
 * GET /broker/{id}
 * PUT /broker
 * 
 */
@RestResource(urlMapping='/symphony/broker/*')
global with sharing class APISymphonyBroker {
    
    @HttpGet
    global static SymphonyBroker getBroker() {
        String id = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1);

        SymphonyBroker symphonyBroker;

        if (String.isNotBlank(id)) {
			List<Contact> contacts = [
                SELECT
                	FirstName, LastName, Email, Phone, Sym_Notify_all_updates_by_email__c, Sym_Notify_all_by_text__c
                FROM
                	Contact
                WHERE
                	Id = :id
            ];

            if (contacts.size() > 0) {
                symphonyBroker = new SymphonyBroker(contacts[0]);
            } else {
                // No record found.
        		RestContext.response.statusCode = 404;
            }
        } else {
        	// Invalid request.
        	RestContext.response.statusCode = 400;    
        }

        return symphonyBroker;
    }

    @HttpPut
    global static SymphonyBroker updateBroker(SymphonyBroker symphonyBroker) {
        System.debug('UPDATE\n\n' + JSON.serialize(symphonyBroker));

        Contact contact = symphonyBroker.toContact();
        update contact;

        return new symphonyBroker(contact);
    }


    global class SymphonyBroker {

		global String id {get; set;}
        global String firstName {get; set;}
        global String lastName {get; set;}
        global String email {get; set;}
        global String phone {get; set;}
        global Boolean notifyByEmail {get; set;}
        global Boolean notifyByText {get; set;}


        global SymphonyBroker() {
        }

        global SymphonyBroker(Contact contact) {
            id = contact.Id;
            firstName = contact.FirstName;
            lastName = contact.LastName;
            email = contact.Email;
            phone = contact.Phone;
            notifyByEmail = contact.Sym_Notify_all_updates_by_email__c;
            notifyByText = contact.Sym_Notify_all_by_text__c;
        }

        public Contact toContact() {
            Contact contact = new Contact();
            contact.Id = id;
            contact.FirstName = firstName;
            contact.LastName = lastName;
            contact.Email = email;
            contact.Phone = phone;
            contact.Sym_Notify_all_updates_by_email__c = notifyByEmail;
            contact.Sym_Notify_all_by_text__c = notifyByText;
            return contact;
        }

    }

}