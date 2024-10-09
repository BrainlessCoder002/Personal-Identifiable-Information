// scanRecords.js
import { LightningElement, track, wire } from 'lwc';
import getObjectList from '@salesforce/apex/ScanCodeCompo.getObjectList'; // Fetch org objects
import startScanProcess from '@salesforce/apex/ScanCodeCompo.startScanProcess'; // Apex method to initiate scan

export default class ScanRecords extends LightningElement {
    @track objectOptions = []; // Holds the list of objects
    @track selectedObject = ''; // Selected object by the user
    @track showResultLink = false; // Toggle link visibility
    scanResultId = ''; // Holds scan result ID for redirection

    // Fetch available objects from org
    @wire(getObjectList)
    wiredObjects({ data, error }) {
        if (data) {
            this.objectOptions = data.map(obj => ({
                label: obj,
                value: obj
            }));
        } else if (error) {
            console.error(error);
        }
    }

    // Handle object selection
    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
    }

    // Initiate the scan process
    startScan() {
        startScanProcess({ objectName: this.selectedObject })
            .then(result => {
                if (result.success) {
                    this.scanResultId = result.scanResultId; // Capture scan result ID
                    this.showResultLink = true; // Show link to scan results
                } else {
                    // Handle error
                    console.error(result.message);
                }
            })
            .catch(error => {
                console.error('Error starting scan:', error);
            });
    }

    // Redirect to scan result page
    redirectToScanResult() {
        window.location.href = `/lightning/r/Scan_Result__c/${this.scanResultId}/view`; // Standard Salesforce record page
    }
}
