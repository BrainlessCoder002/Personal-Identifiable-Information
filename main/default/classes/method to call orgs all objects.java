getobjectOption:
Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();//All objects will be there.
system.debug('Hello boies : '+gd);
Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
Schema.SObjectType sObjectType = globalDescribe.get('Account');
Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
System.debug('Hello Boies'+sObjectType); //Pricts hello object type i.e Account
System.debug('Hello Boies'+describeResult); //Describes about account like getLabel = account, getName  = account

Start scan :
Scan object and scan Date ko insert karna he 
calls the batch PiiRecordScanBatch with selectObject, scanConfig Id 


/*Delete Ki Query*/
List<Scan_Result__c> resultsToDelete = [SELECT Id FROM Scan_Result__c];
delete resultsToDelete;
List<Star_Health_Insurance__c> starToDelete = [SELECT Id FROM Star_Health_Insurance__c];
delete starToDelete;
/****************************************************************************** */
getScanHistory:
not getting updated

        Schema.FieldSet fieldSet = Schema.SObjectType.Scan_Configuration__c.FieldSets.Scan_History; 
        System.debug(fieldSet.getFields());
        Schema.FieldSetMember field = fieldSet.getFields();
        System.debug('Hello Boies:'+field);
Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
Schema.DisplayType fieldType = fieldDescribe.getType();

String rule = '^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20)\\d\\d$';
            Pattern pattern = System.Pattern.compile(rule);
            System.debug('HEllo'+pattern);
            Matcher matcher = pattern.matcher(String.valueOf('02-21-2002'));
            System.debug('Heloo'+matcher);
            if(matcher.matches()){
               System.debug('Heloo'+matcher.group());
            }


            for (Schema.SObjectField field : fieldsMap.values()) {
                String str = field.getDescribe().getName();
                System.debug('str is --: '+str);
                if(str == 'Name'){             
                    Object fieldValue = record.get(field);
                    if (fieldValue != null) {
                        System.debug('Processing field: ' + field.getDescribe().getName() + ' with value: ' + fieldValue);
                        applyRegexRules(field.getDescribe().getName(), fieldValue, rules, record.Id);
                    }
                }
            }

/*****************************************************************************************/

^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$

/*****************************************************************************************/
@AuraEnabled
    public static List<Map<String, Object>> getFieldSetFields() {
    List<Map<String, Object>> columns = new List<Map<String, Object>>();
    
    // Get the field set from the Scan_Configuration__c object
    Schema.FieldSet fieldSet = Schema.SObjectType.Scan_Configuration__c.FieldSets.Scan_History; 
    for (Schema.FieldSetMember field : fieldSet.getFields()) {
        Map<String, Object> fieldInfo = new Map<String, Object>();
        fieldInfo.put('label', field.getLabel());
        fieldInfo.put('fieldName', field.getFieldPath());
        fieldInfo.put('type', getFieldType(field.getSObjectField()));
        columns.add(fieldInfo);
    } 
    
    // Add action column for clickable name
    Map<String, Object> actionColumn = new Map<String, Object>();
    actionColumn.put('label', 'Scan Id');
    actionColumn.put('fieldName', 'Name'); 
    actionColumn.put('type', 'button');
    actionColumn.put('typeAttributes', new Map<String, Object>{
        'label' => '{Name}',  // It will dynamically pull from the row data but not pulling it.
        'variant' => 'base'
    });
    
    columns.add(actionColumn);
    
    return columns;
}

// Helper to determine the type of the field for the datatable
    public static String getFieldType(Schema.SObjectField field) {
    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
    Schema.DisplayType fieldType = fieldDescribe.getType();
    
    // Handling various field types for Lightning DataTable
    if (fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea) {
        return 'text';
    } else if (fieldType == Schema.DisplayType.DateTime) {
        return 'datetime';
    } else {
        return 'text'; 
    }
}


List<Star_Health_Insurance__c> a1 = new List<Star_Health_Insurance__c>();
for (Integer i = 0; i < 1000; i++) {
    Star_Health_Insurance__c acc = new Star_Health_Insurance__c();
    acc.Name = 'Star ' + i; 
    acc.Description__c = '1234-4567-1234'; 
    acc.Phone__c = '+911234567890'; 
    a1.add(acc); 
}
insert a1;

 global void execute(Database.BatchableContext BC, List<SObject> records) {
        // Fetch active REGEX rules
        List<PII_Rule__c> rules = [SELECT Id, PII_Type__c, Regex_Pattern__c FROM PII_Rule__c WHERE isActive__c = TRUE];

        for (SObject record : records) {
            // Skip deleted records
            Boolean isDeleted = (Boolean)record.get('IsDeleted');
            if (isDeleted != null && isDeleted) {
                continue;
            }

            // Iterate through each field of the record
            Map<String, Schema.SObjectField> fieldsMap = record.getSObjectType().getDescribe().fields.getMap();
            for (Schema.SObjectField field : fieldsMap.values()) {
                Object fieldValue = record.get(field);
                if (fieldValue != null) {
                    System.debug('Processing field: ' + field.getDescribe().getName() + ' with value: ' + fieldValue);
                    applyRegexRules(field.getDescribe().getName(), fieldValue, rules, record.Id);
                }
            }
        }
    }
/* --------------------------------------------------------------------------------------------------------*/
    global void finish(Database.BatchableContext BC) {
        //Finish method can be used for Email notifications and other post processing operations
    }
/* --------------------------------------------------------------------------------------------------------*/
private void applyRegexRules(String fieldName, Object fieldValue, List<PII_Rule__c> rules, Id recordId) {
    // Convert field value to string for regex matching
    String fieldValueString = String.valueOf(fieldValue);

    for (PII_Rule__c rule : rules) {
        // Apply the regex to the field value
        if (Pattern.matches(rule.Regex_Pattern__c, fieldValueString)) {
            System.debug('Regex Matched for PII Type: ' + rule.PII_Type__c + ' in field: ' + fieldName);
            // Store detected PII data if regex matches
            storeDetectedPII(rule.PII_Type__c, fieldName, fieldValueString, recordId);
        } else {
            System.debug('No match found for field: ' + fieldName + ' with value: ' + fieldValueString + ' using regex: ' + rule.Regex_Pattern__c);
        }
    }
}
/* --------------------------------------------------------------------------------------------------------*/

    // Store detected PII in Scan_Result__c and link with Scan_Configuration__c
    private void storeDetectedPII(String piiType, String fieldName, String detectedValue, Id recordId) {
        Scan_Result__c result = new Scan_Result__c();
        result.Scan_Object__c = selectedObject;
        result.Field_Name__c = fieldName;
        result.PII_Type_Detected__c = piiType;
        result.Detected_Value__c = detectedValue;
        result.Record_Id__c = recordId;
        result.Scanned_Date__c = Date.today();
        result.Scan_Configuration__c = scanConfigId; // Link the result to the correct scan configuration
    
        // Log the result before insertion
        System.debug('Preparing to insert Scan Result: ' + result);
        try {
            insert result;
        } catch (DmlException e) {
            System.debug('Error inserting Scan Result: ' + e.getMessage());
        }
    }
/* --------------------------------------------------------------------------------------------------------*/
