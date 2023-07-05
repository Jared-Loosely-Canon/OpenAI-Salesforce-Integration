/**
 * @description       : Used to handle the OpenAI Chat API callout and to create new chats and retrieve existing chats.
 *                    : This class is used by the OpenAIChat Lightning Web Component.
 * @author            : Jared Simpson
 * @group             : Loosely Canon LLC
 * @last modified on  : 07-05-2023
 * @last modified by  : Jared Simpson
**/
public with sharing class OpenAiChatController {
    private static OpenAI_Setting__mdt chatSetting = OpenAI_Setting__mdt.getInstance('Chat_Completions_v1');

    /**
    * @description 
    * @author Jared Simpson | 06-16-2023 
    * @param userInput 
    * @param chatId 
    * @return String 
    **/
    @AuraEnabled
    public static String chatWithOpenAI(String userInput, String chatId) {
        try{
            // chatWithOpenAiCallout(UserInfo.getUserId(), userInput, chatId);
            // return 'Chat is running in the background.';
            String result = chatHandler(userInput, chatId);
            return result;
        } catch (Exception e) {
            chatWithOpenAiCallout(UserInfo.getUserId(), userInput, chatId);
            return 'It is taking longer than expected to get a response from OpenAI. The chat will continue to run in the background.';
        }
        
    }

    /**
    * @description Input parameter wrapper class for the invocable method.
    **/
    public class ChatParams {
        @InvocableVariable(label='User Input' required=true)
        public String userInput;

        @InvocableVariable(label='Chat Id' required=true)
        public String chatId;
    }

    /**
    * @description Invocable method for Salesforce flows to call the chatWithOpenAI method.
    **/
    @InvocableMethod(label='Chat with OpenAI')
    public static List<String> invokeChatWithOpenAI(List<ChatParams> paramsList) {
        List<String> results = new List<String>();

        for (ChatParams params : paramsList) {
            String result = chatWithOpenAI(params.userInput, params.chatId);
            results.add(result);
        }

        return results;
    }


    @future(callout=true)
    public static void chatWithOpenAiCallout(Id userId, String userInput, String chatId) {
        // Create an instance of the platform event
        OpenAI_Event__e event = new OpenAI_Event__e();
        event.User_Id__c = userId;
        event.Chat_Id__c = chatId;
        event.Error__c = false;

        try{
            String response = chatHandler(userInput, chatId);
            Database.SaveResult result = EventBus.publish(event);
        } catch (Exception e) {
            System.debug('Error on chatWithOpenAiCallout: ' + e.getMessage());
            event.Error__c = true;
            Database.SaveResult result = EventBus.publish(event);
        }

    }

    private static String chatHandler(String userInput, String chatId){
        OpenAI_Chat_Message__c[] chatMessages = [SELECT Id, Input_Message__c, Output_Message__c 
            FROM OpenAI_Chat_Message__c WITH_SECURITY_ENFORCED WHERE OpenAI_Chat__c = :chatId ORDER BY CreatedDate ASC];
    
        if(chatMessages.size() > 0 && (!Utilities.checkCreateFieldLevelSecurity(chatMessages[0]) || !Utilities.checkUpdateFieldLevelSecurity(chatMessages[0]))) {
            return 'Error: You do not have access to the OpenAI Chat Messages.';
        }

        List<Messages> messages = new List<Messages>();
        for(OpenAI_Chat_Message__c m : chatMessages){
            Messages message = new Messages();
            message.content = m.Input_Message__c != null ? m.Input_Message__c : m.Output_Message__c;
            message.role = m.Input_Message__c != null ? 'user' : 'assistant';
            messages.add(message);
        }

        Messages message = new Messages();
        message.role = 'user';
        message.content = userInput;
        messages.add(message);

        OpenAI_Chat_Message__c newInputChat = new OpenAI_Chat_Message__c(
            Input_Message__c = userInput,
            OpenAI_Chat__c = chatId
        );


        ChatWrapper inputChatWrapper = new ChatWrapper();
        inputChatWrapper.model = chatSetting.model__c;
        inputChatWrapper.messages = messages;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:OpenAI_API/'+chatSetting.Endpoint__c);
        req.setMethod('POST');
        req.setBody(JSON.serialize(inputChatWrapper));
        if(System.isFuture() || System.isBatch() || System.isQueueable()){
            req.setTimeout(120000);
        }

        HttpResponse res = new Http().send(req);

        try{
            Database.SaveResult sr = Database.insert(newInputChat);
        }
        catch(Exception e){
            System.debug('Error on insert of input chat: ' + e.getMessage());
        }

        OpenAiChatWrapper chatWrapper = OpenAiChatWrapper.parse(res.getBody());

        OpenAI_Chat_Message__c newOutputChat = new OpenAI_Chat_Message__c(
            Output_Message__c = chatWrapper.choices[0].message.content,
            OpenAI_Chat__c = chatId
        );

        try {
            Database.SaveResult sr = Database.insert(newOutputChat);
        } catch (Exception e) {
            System.debug('Error on insert of output chat: ' + e.getMessage());
        }

        chatMessages = [SELECT Id, Input_Message__c, Output_Message__c 
            FROM OpenAI_Chat_Message__c WITH_SECURITY_ENFORCED WHERE OpenAI_Chat__c = :chatId ORDER BY CreatedDate ASC];
        
        return JSON.serialize(chatMessages);
    }

    /**
    * @description 
    * @author Jared Simpson | 06-16-2023 
    * @return List<OpenAI_Chat__c> 
    **/
    @AuraEnabled(cacheable=false)
    public static List<OpenAI_Chat__c> getLastChats() {
        // Retrieves the last 10 chats the current user created
        return [SELECT Id, Name FROM OpenAI_Chat__c WITH_SECURITY_ENFORCED WHERE CreatedBy.Id = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 10];
    }

    /**
    * @description 
    * @author Jared Simpson | 06-16-2023 
    * @return String 
    **/
    @AuraEnabled(cacheable=false)
    public static String createNewChat() {
        OpenAI_Chat__c newChat = new OpenAI_Chat__c(model__c=chatSetting.model__c);
        insert newChat;
        return newChat.Id;
    }

    /**
    * @description 
    * @author Jared Simpson | 06-16-2023 
    * @param chatId 
    * @return string 
    **/
    @AuraEnabled(cacheable=false)
    public static string getExistingMessages(String chatId){
        try {
            OpenAI_Chat_Message__c[] chatMessages = [SELECT Id, Input_Message__c, Output_Message__c 
            FROM OpenAI_Chat_Message__c WITH_SECURITY_ENFORCED WHERE OpenAI_Chat__c = :chatId ORDER BY CreatedDate ASC];
            return JSON.serialize(chatMessages);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Used to wrap the response from the OpenAI API callout. This is needed to simplify JSON deserialization
    * @author Jared Simpson | 06-16-2023 
    **/
    public class ChatWrapper{
        public String model;
        public Messages[] messages;
    }

    /**
    * @description Used to wrap the response from the OpenAI API callout. This is needed to simplify JSON deserialization
    * @author Jared Simpson | 06-16-2023 
    **/
    public class Messages {
        public String role;
        public String content;
    } 
}