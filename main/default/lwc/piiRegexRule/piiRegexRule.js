import { LightningElement } from 'lwc';
import saveRegexRule from '@salesforce/apex/RegexRuleController.saveRegexRule';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateRegexRule extends LightningElement {
    // Tracked properties for reactivity
    piiName = '';
    piiType = '';
    regexPattern = '';
    description = '';
    hasError = false;
    errorMessage = '';
    isActive = false;

    // Handles input change events
    handleInputChange(event) {
        const field = event.target.label;
        if (field === 'PII Type') {
            this.piiType = event.target.value;
        } else if (field === 'REGEX Pattern') {
            this.regexPattern = event.target.value;
        } else if (field === 'Description') {
            this.description = event.target.value;
        } else if (field === 'PII Name') {
            this.piiName = event.target.value;
        } else if (field === 'Is Active') {
            this.isActive = event.target.checked;
        }
    }

    // Validates and submits the form
    handleSaveRule() {
        // Input validation
        if (!this.piiType || !this.regexPattern) {
            this.hasError = true;
            this.errorMessage = 'PII Type and REGEX Pattern are required!';
            return;
        }
        // Clear previous error message
        this.hasError = false;
        this.errorMessage = '';
        // Apex method call to save rule
        saveRegexRule({
            piiName: this.piiName,
            piiType: this.piiType,
            regexPattern: this.regexPattern,
            description: this.description,
            isActive: this.isActive
        })
        .then(() => {
            this.showToast('Success', 'Regex rule saved successfully', 'success');
            this.handleClearForm(); 
        })
        .catch(error => {
            this.hasError = true;
            this.errorMessage = 'Error saving rule: ' + error.body.message;
        });
    }

    // Clears the form
    handleClearForm() {
        this.piiName = '';
        this.piiType = '';
        this.regexPattern = '';
        this.description = '';
        this.hasError = false;
        this.errorMessage = '';
    }

    // Show toast messages for success/error feedback
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
