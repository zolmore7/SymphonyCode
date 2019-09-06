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
    currentStatus;
    picklistValues = ['Customer setup is initiated','Customer setup is Completed','Member Enrollment Complete','Billing is activated and ID cards are available'];

    movePath() {
        getCase({ theId : this.recId})
        .then(result => {
            this.data = result;
            this.currentStatus = this.data.Sym_Case_Status__c;
            console.log(this.currentStatus);
            if((this.currentStatus !== 'Billing is activated and ID cards are available') && (this.currentStatus !== 'Customer setup is initiated')) {
                updateRecord({ theId : this.recId})
                .then(result2 => {
                    this.data = result2;
                    console.log(this.data);
                        window.location.reload();
                        callBrokerPortal({ theId : this.recId});     
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                });
            }
        })
    }

    connectedCallback() {
        this.recId = this.recordId;
        setTimeout(() => {
            this.movePath();
        }, 30000);
    }

}