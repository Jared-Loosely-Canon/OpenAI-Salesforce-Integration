/**
 * @description       : Helper class for test data creation
 * @author            : Jared Simpson
 * @group             : Loosely Canon LLC
 * @last modified on  : 06-16-2023
 * @last modified by  : Jared Simpson
**/
public without sharing class TestDataHelper {
    public static User createSystemUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='OpenAI_Admin_Access'];
        User u = new User(
            ProfileId = p.Id,
            FirstName = 'Test',
            LastName = 'Admin',
            Email = 'ldkas8@alsdtestyadmin.com',
            Username = 'ldkas8@alsdtestyadmin.com',
            Alias = 't78ehad',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        assignPermission(u.Id);

        return u;
    }

    @future(callout=false)
    public static void assignPermission(String id){
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='OpenAI_Admin_Access'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=id);
        insert psa;
    }
}