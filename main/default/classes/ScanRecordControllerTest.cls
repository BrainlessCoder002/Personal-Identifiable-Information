/*******************************************************************************************************
* @Author:          Om Diwakar
* @TestClass:       ScanRecordControllerTest
* @Description:     A class which Test the different methods in the class
*******************************************************************************************************
* Version           Author              Date (DD-MM-YYYY)           Description
* 1.0               Om Diwakar          26-09-2024                  Initial Build
*******************************************************************************************************/
@IsTest
public with sharing class ScanRecordControllerTest {
    @IsTest
    public static void testGetObjectOptionsSize() {
        Test.startTest();
        List<Map<String, String>> objectOptions = ScanRecordController.getObjectOptions();
        Test.stopTest();
        
        Assert.isTrue(objectOptions.size() > 0, 'The object options list should not be empty.');
    } 
/* --------------------------------------------------------------------------------------------------------*/ 
    @IsTest
    public static void testGetObjectOptionsPresent() {
        Test.startTest();
        List<Map<String,String>> objectOptions = ScanRecordController.getObjectOptions();
        Test.stopTest();

        Boolean accountFound = false;
        for (Map<String,String> objectOption : objectOptions) {
            if (objectOption.get('value') == 'Account') {
                String label = objectOption.get('label');
                accountFound = true;
                Assert.isTrue(accountFound, 'The Account object should be present in the list of objects');
            }
        }
    }
/* --------------------------------------------------------------------------------------------------------*/
    @IsTest
    public static void testStartScan() {
       String selectedObject = TestDataFactory.getMockObjectName();

        Test.startTest();
        Id scanConfigId = ScanRecordController.startScan(selectedObject);
        Test.stopTest();
        
        Scan_Configuration__c scanConfig = [
            SELECT 
                Id, Scan_Object__c, Scan_Date__c 
            FROM 
                Scan_Configuration__c 
            WHERE 
                Id = :scanConfigId
        ];

        Assert.isNotNull(scanConfigId, 'The Scan Configuration ID should not be null.');
        Assert.areEqual(selectedObject, scanConfig.Scan_Object__c, 'The selected object should match the Scan_Object__c.');
        Assert.areEqual(Date.today(), scanConfig.Scan_Date__c, 'The Scan_Date__c should be today\'s date.');
    }
/* --------------------------------------------------------------------------------------------------------*/
    @IsTest
    public static void testStartScanBatchExecution() {
        String selectedObject = TestDataFactory.getMockObjectName();

        Test.startTest();
        Id scanConfigId = ScanRecordController.startScan(selectedObject);
        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT 
                Id, Status, JobItemsProcessed, NumberOfErrors 
            FROM 
                AsyncApexJob 
            WHERE 
                JobType = 'BatchApex' AND ApexClass.Name = 'PiiRecordScanBatch'
        ];

        Assert.isTrue(jobs.size() > 0, 'The batch job should have been enqueued.');
    }
/* --------------------------------------------------------------------------------------------------------*/
    @IsTest
    public static void testGetScanHistory() {
        List<Scan_Configuration__c> testScanConfigs = TestDataFactory.getMockScanHistory(5);
        insert testScanConfigs;
        
        Test.startTest();
        List<Scan_Configuration__c> scanHistory = ScanRecordController.getScanHistory();
        Test.stopTest();
        
        for (Integer i = 0; i < scanHistory.size() - 1; i++) {
            System.debug('Name :'+scanHistory);  
            Assert.isTrue(scanHistory[i].Name >= scanHistory[i + 1].Name, 'Records should be ordered by Name in descending order.');
        }
    }
/* --------------------------------------------------------------------------------------------------------*/
}