public with sharing class ContactsService {
    public ContactsService() {

    }
    public static List<Contact> getContacts() {
        return [SELECT Id, FirstName, LastName, Email FROM Contact WITH SECURITY_ENFORCED];
    }
}