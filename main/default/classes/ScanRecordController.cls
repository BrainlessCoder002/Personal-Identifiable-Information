/*******************************************************************************************************
* @Author:          Om Diwakar
* @Class:           ScanRecordController
* @Description:     A controller class which get Object Options , Scan History and 
*                   start the batch job
*******************************************************************************************************
* Version           Author              Date (DD-MM-YYYY)           Description
* 1.0               Om Diwakar          26-09-2024                  Initial Build
*******************************************************************************************************/
public with sharing class ScanRecordController {

    // Wrapper class to hold the combined results
    public class ScanDataWrapper {
        @AuraEnabled public List<Map<String, String>> objectOptions { get; set; }
        @AuraEnabled public List<Scan_Configuration__c> scanHistory { get; set; }
        @AuraEnabled public List<Map<String, String>> fieldSetFields { get; set; }
        
        public ScanDataWrapper() {
            this.objectOptions = new List<Map<String, String>>();
            this.scanHistory = new List<Scan_Configuration__c>();
            this.fieldSetFields = new List<Map<String, String>>();
        }
    }
    
    @AuraEnabled
    public static ScanDataWrapper getScanHistory() {
        ScanDataWrapper scanData = new ScanDataWrapper();
        
        // Fetch object options
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for (String objName : globalDescribe.keySet()) {
            Schema.SObjectType sObjectType = globalDescribe.get(objName);
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            Map<String, String> option = new Map<String, String>();
            option.put('label', describeResult.getLabel()); 
            option.put('value', objName); 
            scanData.objectOptions.add(option);
        }

        // Fetch recent scan history
        scanData.scanHistory = [
            SELECT Name, Scan_Object__c, Scan_Date__c
            FROM Scan_Configuration__c 
            ORDER BY Name DESC
            LIMIT 100
        ];

        // Fetch field set fields
        Schema.FieldSet fieldSet = Schema.SObjectType.Scan_Configuration__c.FieldSets.Scan_History;
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            Map<String, String> fieldInfo = new Map<String, String>();
            fieldInfo.put('label', field.getLabel());
            fieldInfo.put('fieldName', field.getFieldPath());
            fieldInfo.put('type', getFieldType(field.getSObjectField()));
            scanData.fieldSetFields.add(fieldInfo);
        }
        return scanData;
    }
    
    // Helper method to get field type
    public static String getFieldType(Schema.SObjectField field) {
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        Schema.DisplayType fieldType = fieldDescribe.getType();
        
        if (fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea) {
            return 'text';
        } else if (fieldType == Schema.DisplayType.Date) {
            return 'date';
        } else {
            return 'text';
        }
    }
    
    @AuraEnabled
    public static Id startScan(String selectedObject) {
        // Create Scan Configuration
        Scan_Configuration__c scanConfig = new Scan_Configuration__c();
        scanConfig.Scan_Object__c = selectedObject;
        scanConfig.Scan_Date__c = Datetime.now();
        
        try {
            insert scanConfig;
        } catch (Exception e) {
            return null;
        }
        
        // Start batch process
        PiiRecordScanBatch batch = new PiiRecordScanBatch(selectedObject, scanConfig.Id);
        Database.executeBatch(batch);
        
        return scanConfig.Id;
    }
}

