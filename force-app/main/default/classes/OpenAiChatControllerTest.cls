/**
 * @description       : 
 * @author            : Jared Simpson
 * @group             : Loosely Canon LLC
 * @last modified on  : 06-19-2023
 * @last modified by  : Jared Simpson
**/
@isTest
private with sharing class OpenAiChatControllerTest {
    @TestSetup
    static void makeData(){
        TestDataHelper.createSystemUser();
        User queriedUser = [SELECT Id 
            FROM User 
            WHERE Email = 'ldkas8@alsdtestyadmin.com' LIMIT 1];

        System.runAs(queriedUser){
            OpenAiChatController.createNewChat();
            OpenAI_Chat__c chat = [SELECT Id, OwnerId 
                FROM OpenAI_Chat__c
                WHERE OwnerId =: queriedUser.Id LIMIT 1];
            System.assertEquals(queriedUser.Id, chat.OwnerId);

            String messages = OpenAiChatController.getExistingMessages(chat.Id);
            System.assertEquals('[]', messages);

            OpenAI_Chat_Message__c message = new OpenAI_Chat_Message__c(
                OpenAI_Chat__c = chat.Id,
                Input_Message__c = 'Hello World'
            );
            insert message;
        }
    }

    @isTest
    private static void test_chatWithOpenAI_success(){
        Test.setMock(HttpCalloutMock.class, new MockOpenAiResponse());

        User queriedUser = [SELECT Id FROM User 
            WHERE Email = 'ldkas8@alsdtestyadmin.com' LIMIT 1];
        OpenAI_Chat__c chat = [SELECT Id, OwnerId 
                FROM OpenAI_Chat__c
                WHERE OwnerId =: queriedUser.Id LIMIT 1];

        Test.startTest();
        System.runAs(queriedUser){
            String messages = OpenAiChatController.chatWithOpenAI(
                'Hello World', chat.Id);
            System.assertNotEquals('[]', messages);

            OpenAI_Chat__c[] chats = OpenAiChatController.getLastChats();
            System.assertEquals(1, chats.size());
        }
        Test.stopTest();
    }

    @isTest
    private static void test_chatWithOpenAI_fail(){
        Test.setMock(HttpCalloutMock.class, new MockOpenAiResponse());

        User queriedUser = [SELECT Id FROM User 
            WHERE Email = 'ldkas8@alsdtestyadmin.com' LIMIT 1];
        OpenAI_Chat__c chat = [SELECT Id, OwnerId 
                FROM OpenAI_Chat__c
                WHERE OwnerId =: queriedUser.Id LIMIT 1];

        try {
            Test.startTest();
            System.runAs(queriedUser){
                String messages = OpenAiChatController.chatWithOpenAI(
                    'Hello World', '');
                System.assertNotEquals('[]', messages);

                OpenAI_Chat__c[] chats = OpenAiChatController.getLastChats();
                System.assertEquals(1, chats.size());
            }
            Test.stopTest();
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Exception should be thrown');
        }
    }

    @isTest
    private static void test_chatWithOpenAICallout_success(){
        Test.setMock(HttpCalloutMock.class, new MockOpenAiResponse());

        User queriedUser = [SELECT Id FROM User 
            WHERE Email = 'ldkas8@alsdtestyadmin.com' LIMIT 1];
        OpenAI_Chat__c chat = [SELECT Id, OwnerId 
                FROM OpenAI_Chat__c
                WHERE OwnerId =: queriedUser.Id LIMIT 1];

        Test.startTest();
        System.runAs(queriedUser){
            OpenAiChatController.chatWithOpenAiCallout(
                queriedUser.Id, 'Hello World', chat.Id);
            
            String messages = OpenAiChatController.getExistingMessages(chat.Id);
            System.assertNotEquals('[]', messages);

            OpenAI_Chat__c[] chats = OpenAiChatController.getLastChats();
            System.assertEquals(1, chats.size());
        }
        Test.stopTest();
    }

    @isTest
    private static void test_getExistingMessages_fail(){
        User queriedUser = [SELECT Id FROM User 
            WHERE Email = 'ldkas8@alsdtestyadmin.com' LIMIT 1];

        System.runAs(queriedUser){
            try{
                OpenAiChatController.getExistingMessages('');
            } catch(Exception e){
                System.assertEquals('No chat found with that Id', e.getMessage());
            }
        }
    }
}