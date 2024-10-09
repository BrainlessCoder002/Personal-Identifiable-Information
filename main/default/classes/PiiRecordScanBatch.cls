/*******************************************************************************************************
* @Author:          Om Diwakar
* @Class:           PiiRecordScanBatch
* @Description:     A Batch class which scans the selected object and detects PII fields
*                   and stores the results in the Scan_Result__c object
*******************************************************************************************************
* Version           Author              Date (DD-MM-YYYY)           Description
* 1.0               Om Diwakar          26-09-2024                  Initial Build
*******************************************************************************************************/
global class PiiRecordScanBatch implements Database.Batchable<SObject>, Database.Stateful {
    // Variables to hold detected PII results and configuration
    Scan_Configuration__c scanConfigs;
    String selectedObject;
    Id scanConfigId; 

    // Constructor to initialize the batch with object and scan configuration ID
    public PiiRecordScanBatch(String selectedObject, Id scanConfigId) {
        this.selectedObject = selectedObject;
        this.scanConfigId = scanConfigId;  
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Describe and retrieve fields from the selected object
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(selectedObject);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        List<Schema.SObjectField> fields = describeResult.fields.getMap().values();
        List<String> fieldNames = new List<String>();

        // Construct field names list
        for (Schema.SObjectField field : fields) {
            fieldNames.add(field.getDescribe().getName());
        }

        // Construct the query to fetch records from the selected object
        String query = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + selectedObject;
        return Database.getQueryLocator(query);
    }
    
/* --------------------------------------------------------------------------------------------------------*/
    global void execute(Database.BatchableContext BC, List<SObject> records) {
        // Fetch active REGEX rules
        List<PII_Rule__c> rules = [
            SELECT 
                Id, PII_Type__c, Regex_Pattern__c 
            FROM 
                PII_Rule__c 
            WHERE 
                isActive__c = TRUE
            ];

        // List to store detected PII records
        List<Scan_Result__c> detectedPIIResults = new List<Scan_Result__c>();

        // Map to store field values for all records (record Id => field values map)
        Map<Id, Map<String, String>> allRecordFieldValues = new Map<Id, Map<String, String>>();

        // Collect field values for all records
        for (SObject record : records) {
            Map<String, Schema.SObjectField> fieldsMap = record.getSObjectType().getDescribe().fields.getMap();
            Map<String, String> fieldValues = new Map<String, String>();

            // Collect non-null field values for each record
            for (Schema.SObjectField field : fieldsMap.values()) {
                Object fieldValue = record.get(field);
                if (fieldValue != null && String.valueOf(fieldValue).trim() != '') {
                    fieldValues.put(field.getDescribe().getName(), String.valueOf(fieldValue));
                }
            }

            // Store the field values for this record
            allRecordFieldValues.put(record.Id, fieldValues);
        }

        //  Apply regex rules in bulk to all collected field values
        applyRegexRules(allRecordFieldValues, rules, detectedPIIResults);

        // Bulk insert the detected PII records after processing all records
        if (!detectedPIIResults.isEmpty()) {
            try {
                insert detectedPIIResults;
            } catch (DmlException e) {
                System.debug('Error inserting scan results: ' + e.getMessage());
            }
        }   
    }


/* --------------------------------------------------------------------------------------------------------*/

    public void finish(Database.BatchableContext bc){}

/* --------------------------------------------------------------------------------------------------------*/

    private void applyRegexRules(Map<Id, Map<String, String>> allRecordFieldValues, List<PII_Rule__c> rules, List<Scan_Result__c> detectedPIIResults) {
        // Create a map to store compiled patterns and their corresponding PII types
        Map<Pattern, String> compiledPatterns = new Map<Pattern, String>();
    
        // Pre-compile regex patterns for performance
        for (PII_Rule__c rule : rules) {
            compiledPatterns.put(Pattern.compile(rule.Regex_Pattern__c), rule.PII_Type__c);
        }

        // Iterate through the record field values
        for (Id recordId : allRecordFieldValues.keySet()) {
            Map<String, String> fieldValues = allRecordFieldValues.get(recordId);

            // For each field in the record
            for (String fieldName : fieldValues.keySet()) {
                String fieldValueString = fieldValues.get(fieldName);

                // Apply all compiled regex patterns to the field value
                for (Pattern pattern : compiledPatterns.keySet()) {`
                    Matcher matcher = pattern.matcher(fieldValueString);
                
                    // If a match is found, create a Scan_Result__c record
                    if (matcher.matches()) {
                        String piiType = compiledPatterns.get(pattern);
                        System.debug('Regex Matched for PII Type: ' + piiType + ' in field: ' + fieldName);

                        // Create the result record
                        Scan_Result__c result = new Scan_Result__c(
                        Scan_Object__c = selectedObject,
                        Field_Name__c = fieldName,
                        PII_Type_Detected__c = piiType,
                        Detected_Value__c = fieldValueString,
                        Record_Id__c = recordId,
                        Scanned_Date__c = Date.today(),
                        Scan_Configuration__c = scanConfigId
                    );
                    
                    detectedPIIResults.add(result);
                    }
                }
            }
        }
    }
}


