/*******************************************************************************************************
* @Author:          Om Diwakar
* @TestClass:       RegexRuleControllerTest
* @Description:     A class which Test the regex rule and creates the PII Rule record
*******************************************************************************************************
* Version           Author              Date (DD-MM-YYYY)           Description
* 1.0               Om Diwakar          26-09-2024                  Initial Build
*******************************************************************************************************/
@IsTest
public class RegexRuleControllerTest {
    
    @IsTest
    public static void testSaveRegexRulePositve() {
        List<String> piiValueList = TestDataFactory.getMockPiiRuleData();

        String piiName = piiValueList[0];
        String piiType = piiValueList[1];
        String regexPattern = piiValueList[2];
        String description = piiValueList[3];
        insert new PII_Rule__c(Name = piiName, PII_Type__c = piiType, REGEX_Pattern__c = regexPattern, Description__c = description, isActive__c = true);
        
        Test.startTest();
        RegexRuleController.saveRegexRule(piiName, piiType, regexPattern, description);
        Test.stopTest();

        PII_Rule__c insertedRule = [
            SELECT 
                Name, PII_Type__c, REGEX_Pattern__c, Description__c, isActive__c 
            FROM 
                PII_Rule__c 
            WHERE 
                Name = :piiName LIMIT 1
        ];
                                     
        Assert.areEqual(piiName, insertedRule.Name, 'The PII Name does not match');
        Assert.areEqual(piiType, insertedRule.PII_Type__c, 'The PII Type does not match');
        Assert.areEqual(regexPattern, insertedRule.REGEX_Pattern__c, 'The REGEX Pattern does not match');
        Assert.areEqual(description, insertedRule.Description__c, 'The description does not match');
        Assert.isTrue(insertedRule.isActive__c, 'The isActive flag should be true');
        
    }
/* --------------------------------------------------------------------------------------------------------*/ 

    @IsTest
    public static void testSaveRegexRuleNegative() {
        List<String> piiValueList = TestDataFactory.getMockPiiRuleData();

        String piiName = piiValueList[0];
        String piiType = piiValueList[1];
        String regexPattern = piiValueList[2];
        String description = piiValueList[3];
        insert new PII_Rule__c(Name = piiName, PII_Type__c = piiType, REGEX_Pattern__c = regexPattern, Description__c = description, isActive__c = true);
        
        Test.startTest();
        try {
            RegexRuleController.saveRegexRule(piiName, piiType, '',description);
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Error message does not match');
        }
        Test.stopTest();
    }
}
