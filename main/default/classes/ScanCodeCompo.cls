// ScanController.cls
public with sharing class ScanCodeCompo {

    @AuraEnabled(cacheable=true)
    public static List<String> getObjectList() {
        List<String> objectNames = new List<String>();

        // Fetch all objects available in the org
        for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
            objectNames.add(objType.getDescribe().getName());
        }
        return objectNames;
    }

    @AuraEnabled
    public static Map<String, Object> startScanProcess(String objectName) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            // Perform the scan logic (pseudocode)
            // Fetch records, apply REGEX rules, and detect PII
            List<SObject> records = [SELECT Id FROM :objectName]; // Get records for the selected object
            for (SObject record : records) {
                // Iterate fields and apply REGEX rules
                // If PII detected, store scan result
            }

            // Create ScanResult__c record (assuming ScanResult__c is a custom object)
            ScanResult__c scanResult = new ScanResult__c();
            scanResult.Object_Name__c = objectName;
            scanResult.Date_Scanned__c = Date.today();
            insert scanResult;

            response.put('success', true);
            response.put('scanResultId', scanResult.Id); // Return scan result ID
        } catch (Exception e) {
            response.put('success', false);
            response.put('message', e.getMessage());
        }

        return response;
    }
}
