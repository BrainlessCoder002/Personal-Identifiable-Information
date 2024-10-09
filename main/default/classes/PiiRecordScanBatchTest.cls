/*******************************************************************************************************
* @Author:          Om Diwakar
* @TestClass:       PiiRecordScanBatchTest
* @Description:     A class which Test the different methods in the class
*******************************************************************************************************
* Version           Author              Date (DD-MM-YYYY)           Description
* 1.0               Om Diwakar          26-09-2024                  Initial Build
*******************************************************************************************************/
@IsTest
public class PiiRecordScanBatchTest {

    @IsTest
    public static void testBatchExecution() {
        Scan_Configuration__c scanConfig = TestDataFactory.getScanConfiguration();
        insert scanConfig;
        List<PII_Rule__c> piiRuleList = TestDataFactory.getPIIRules();
        insert piiRuleList;
        List<Star_Health_Insurance__c> testAccountList = TestDataFactory.getTestAccounts(200);
        insert testAccountList;

        Test.startTest();
        PiiRecordScanBatch batch = new PiiRecordScanBatch('Star_Health_Insurance__c', scanConfig.Id);
        Database.executeBatch(batch);
        Test.stopTest();
        
        
        List<Scan_Result__c> scanResults = [
            SELECT 
                Id, PII_Type_Detected__c, Field_Name__c, Detected_Value__c, Record_Id__c
            FROM 
                Scan_Result__c
            WHERE 
                Scan_Configuration__c = :scanConfig.Id
        ];

        // Check individual scan results for accuracy
        for (Scan_Result__c result : scanResults) {
            if (result.PII_Type_Detected__c == 'Email') {
                Assert.isTrue(result.Detected_Value__c.contains('@example.com'), 'Email PII should be detected.');
            } else if (result.PII_Type_Detected__c == 'Phone') {
                Assert.isTrue(result.Detected_Value__c.startsWith('123-456-'), 'Phone PII should be detected.');
            }
        }
    }
    @IsTest
    public static void testNoPIIDetection() {
        Scan_Configuration__c scanConfig = TestDataFactory.getScanConfiguration();
        insert scanConfig;
        List<PII_Rule__c> piiRuleList = TestDataFactory.getPIIRules();
        insert piiRuleList;
        List<Star_Health_Insurance__c> testAccountList = TestDataFactory.getTestAccountsNoPII(200);
        insert testAccountList;

        Test.startTest();
        PiiRecordScanBatch batch = new PiiRecordScanBatch('Star_Health_Insurance__c', scanConfig.Id);
        Database.executeBatch(batch);
        Test.stopTest();
        
        
        List<Scan_Result__c> scanResults = [
            SELECT 
                Id, PII_Type_Detected__c, Field_Name__c, Detected_Value__c, Record_Id__c
            FROM 
                Scan_Result__c
            WHERE 
                Scan_Configuration__c = :scanConfig.Id
        ];

        // Assert no scan results for accuracy
        Assert.isTrue(scanResults.isEmpty(), 'No PII data should have been detected.');
    }
    @IsTest
    public static void testInvalidRegexRule() {
        Scan_Configuration__c scanConfig = TestDataFactory.getScanConfiguration();
        insert scanConfig;
        List<PII_Rule__c> piiRuleList = TestDataFactory.getInvalidPIIRules();
        insert piiRuleList;
        List<Star_Health_Insurance__c> testAccountList = TestDataFactory.getTestAccounts(200);
        insert testAccountList;

        Test.startTest();
        PiiRecordScanBatch batch = new PiiRecordScanBatch('Star_Health_Insurance__c', scanConfig.Id);
        Database.executeBatch(batch);
        Test.stopTest();

        List<Scan_Result__c> scanResults = [
            SELECT 
                Id, PII_Type_Detected__c, Field_Name__c, Detected_Value__c, Record_Id__c
            FROM 
                Scan_Result__c
            WHERE 
                Scan_Configuration__c = :scanConfig.Id
        ];

        Assert.areEqual(0, scanResults.size(), 'No Invalid PII data should have been detected.');
    }
}
