/**
 * @description       : 
 * @author            : Jared Simpson
 * @group             : Loosely Canon LLC
 * @last modified on  : 06-16-2023
 * @last modified by  : Jared Simpson
**/
@isTest
private without sharing class TestDataHelperTest {
    @TestSetup
    private static void makeData(){
        User u = TestDataHelper.createSystemUser();
    }
    
    @isTest
    private static void createSystemUser() {
        User queriedUser = [SELECT Id FROM User WHERE Email = 'ldkas8@alsdtestyadmin.com' LIMIT 1];

        // Assert that the user was successfully inserted
        System.assertNotEquals(null, queriedUser, 'User should be successfully inserted.');
        
        // Query the permission set assignment from the database
        PermissionSetAssignment psa = [
            SELECT Id, PermissionSet.Name 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :queriedUser.Id 
            AND PermissionSet.Name = 'OpenAI_Admin_Access'
        ];
        
        // Assert that the permission set was successfully assigned
        System.assertNotEquals(null, psa, 'Permission set should be successfully assigned.');
    }
}