import { LightningElement, track } from 'lwc';
//import getObjectOptions from '@salesforce/apex/ScanRecordController.getObjectOptions';
import startScan from '@salesforce/apex/ScanRecordController.startScan';
// import getScanHistory from '@salesforce/apex/ScanRecordController.getScanHistory';
// import getFieldSetFields from '@salesforce/apex/ScanRecordController.getFieldSetFields';
import { NavigationMixin } from 'lightning/navigation';

import getScanData from '@salesforce/apex/ScanRecordController.getScanData';


export default class ScanRecords extends NavigationMixin(LightningElement) {
    selectedObject = '';
    @track objectOptions = [];
    @track scanHistory = [];
    @track columns = [];
    errorMessage = '';
    isLoading = false;
    intervalId;

    connectedCallback() {
        this.loadScanData();
        // Set up an interval to fetch data every 60 seconds (60000 ms)
        this.intervalId = setInterval(() => {
            this.loadScanData();
        }, 60000);
    }

    disconnectedCallback() {
        // Clear the interval when the component is removed
        clearInterval(this.intervalId);
    }

    loadScanData() {
        this.isLoading = true;
        getScanData()
            .then(result => {
                this.objectOptions = result.objectOptions.map(obj => ({
                    label: obj.label,
                    value: obj.value
                }));
                this.scanHistory = result.scanHistory;
                // Add action column for clickable name
                this.columns = result.fieldSetFields.concat([
                    {
                        label: 'Scan Id',
                        fieldName: 'Name',
                        type: 'button',
                        typeAttributes: {
                            label: { fieldName: 'Name' },
                            variant: 'base'
                        }
                    }
                ]);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = 'Error loading scan data: ' + error.body.message;
            });
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
    }

    handleScanClick() {
        if (!this.selectedObject) {
            this.errorMessage = 'Please select an object to scan.';
            return;
        }
        this.errorMessage = '';
        this.isLoading = true;

        startScan({ selectedObject: this.selectedObject })
            .then(() => {
                this.isLoading = false;
                this.loadScanData();
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = 'Error starting scan: ' + error.body.message;
            });
    }

    // Handle row action for Scan Name click
    handleRowAction(event) {
        const row = event.detail.row;
        const scanConfigId = row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: scanConfigId,
                objectApiName: 'Scan_Configuration__c',
                relationshipApiName: 'Scan_Results__r',
                actionName: 'view',
            },
        });
    }
}

