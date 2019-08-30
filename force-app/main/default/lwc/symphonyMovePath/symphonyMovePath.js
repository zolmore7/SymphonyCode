/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from 'lwc';
import updateRecord from '@salesforce/apex/SymphonyTimeStatus.movePath';
import callBrokerPortal from '@salesforce/apex/SymphonyTimeStatus.callBrokerPortal';
import getCase from '@salesforce/apex/SymphonyTimeStatus.getCase';

export default class SymphonyMovePath extends LightningElement {

    @api recordId;
    @track recId;
    @track data;
    @track error;
    @track status;
    @track currentStatus;
    picklistValues = ['Customer setup is initiated','Customer setup is Completed','Member Enrollment Complete','Billing is activated and ID cards are available'];

    movePath() {
        getCase({ theId : this.recId})
        .then(result => {
            this.data = result;
            this.currentStatus = this.data.Sym_Case_Status__c;
            console.log(this.data.Sym_Case_Status__c);
        })

        updateRecord({ theId : this.recId})
        .then(result => {
            this.data = result;
            console.log(this.data);
            if(this.currentStatus !== 'Customer setup is Completed') {
                window.location.reload();
                callBrokerPortal({ theId : this.recId});
            }

        })
        .catch(error => {
            this.error = error;
            console.log(JSON.stringify(error));
        });
    }

    connectedCallback() {
        this.recId = this.recordId;
        setTimeout(() => {
            this.movePath();
        }, 10000);
    }

}