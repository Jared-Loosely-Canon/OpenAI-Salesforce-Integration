// Create an instance of the platform event
OpenAI_Event__e event = new OpenAI_Event__e();
event.User_Id__c = '00504000003zMfoAAE';
event.Chat_Id__c = 'a01040000028ronAAA';

// Publish the event
Database.SaveResult result = EventBus.publish(event);

// Check if the event was successfully published
if (result.isSuccess()) {
    System.debug('Event published successfully!');
} else {
    for(Database.Error error : result.getErrors()) {
        System.debug('Error while publishing event: ' + error.getMessage());
    }
}
