/*******************************************************************************************************
* @Author:          Om Diwakar
* @Class:           RegexRuleController
* @Description:     A class which saves the regex rule and creates the PII Rule record
*******************************************************************************************************
* Version           Author              Date (DD-MM-YYYY)           Description
* 1.0               Om Diwakar          26-09-2024                  Initial Build
*******************************************************************************************************/
public with sharing class RegexRuleController {
    @AuraEnabled
    public static void saveRegexRule(String piiName, String piiType, String regexPattern, String description) {
        if (String.isBlank(piiType) || String.isBlank(regexPattern)) {
            throw new AuraHandledException('PII Type and REGEX Pattern are required.');
        }

        PII_Rule__c rule = new PII_Rule__c();
        rule.Name = piiName;
        rule.PII_Type__c = piiType;
        rule.REGEX_Pattern__c = regexPattern;
        rule.Description__c = description;
        rule.isActive__c = true;
        insert rule;
    }
/* --------------------------------------------------------------------------------------------------------*/
}
