public with sharing class TestDataFactory {

    public static List<String> getMockPiiRuleData() {
        List<String> piiData = new List<String>();
        piiData.add('Test PII Rule'); 
        piiData.add('Email'); 
        piiData.add('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'); 
        piiData.add('Test regex for email validation'); 
        
        return piiData;
    }

    public static String getMockObjectName() {
        String selectedObject = 'Account'; 
        return selectedObject;
    }

    public static List<Scan_Configuration__c> getMockScanHistory(Integer numberOfRecords) {
        List<Scan_Configuration__c> scanConfigs = new List<Scan_Configuration__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Scan_Configuration__c scanConfig = new Scan_Configuration__c(
                Scan_Object__c = 'Account',
                Scan_Date__c = Date.today().addDays(+i) 
            );
            scanConfigs.add(scanConfig);
        }
        return scanConfigs; 
    }
    
    public static Scan_Configuration__c getScanConfiguration() {
        Scan_Configuration__c scanConfig = new Scan_Configuration__c(
            Scan_Object__c = 'Star_Health_Insurance__c',
            Scan_Date__c = Date.today()
        );
        return scanConfig;
    }

    public static List<PII_Rule__c> getPIIRules() {
        List<PII_Rule__c> piiRules = new List<PII_Rule__c>();
        piiRules.add(new PII_Rule__c(
            Name = 'Email Rule',
            PII_Type__c = 'Email',
            Regex_Pattern__c = '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}',
            isActive__c = true
        ));
        piiRules.add(new PII_Rule__c(
            Name = 'Phone Number Rule',
            PII_Type__c = 'Phone',
            Regex_Pattern__c = '\\d{3}-\\d{3}-\\d{4}',
            isActive__c = true
        ));
        return piiRules;
    }

    public static List<Star_Health_Insurance__c> getTestAccounts(Integer numberOfRecords) {
        List<Star_Health_Insurance__c> insurance = new List<Star_Health_Insurance__c>();
        for(Integer i=0;i<numberOfRecords;i++){
            Star_Health_Insurance__c starHealth = new Star_Health_Insurance__c
                                                    (Name = 'Star Health' + i,
                                                    Email__c = 'test' + i + '@example.com',
                                                    Phone__c = '123-456-' + String.valueOf(7000 + i)
                                                    );
            insurance.add(starHealth);
        }
        return insurance;
    }

    public static List<Star_Health_Insurance__c> getTestAccountsNoPII(Integer numberOfRecords) {
        List<Star_Health_Insurance__c> insurance = new List<Star_Health_Insurance__c>();
        for(Integer i=0;i<numberOfRecords;i++){
            Star_Health_Insurance__c starHealth = new Star_Health_Insurance__c
                                                    (Name = 'Star Health' + i,
                                                    Email__c = '',
                                                    Phone__c = ''
                                                    );
            insurance.add(starHealth);
        }
        return insurance;
    }

    public static List<PII_Rule__c> getInvalidPIIRules() {
        List<PII_Rule__c> piiRules = new List<PII_Rule__c>();
        piiRules.add(new PII_Rule__c(
            Name = 'Email Rule',
            PII_Type__c = 'Email',
            Regex_Pattern__c = '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.  [a-zA-Z]{2,}',
            isActive__c = true
        ));
        piiRules.add(new PII_Rule__c(
            Name = 'Phone Number Rule',
            PII_Type__c = 'Phone',
            Regex_Pattern__c = '[invalid_regex]',
            isActive__c = true
        ));
        return piiRules;
    }
}