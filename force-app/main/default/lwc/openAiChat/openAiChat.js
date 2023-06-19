import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, onError, } from 'lightning/empApi';
import Id from '@salesforce/user/Id';


import chatWithOpenAI from '@salesforce/apex/OpenAiChatController.chatWithOpenAI';
import getLastChats from '@salesforce/apex/OpenAiChatController.getLastChats';
import createNewChat from '@salesforce/apex/OpenAiChatController.createNewChat';
import getExistingMessages from '@salesforce/apex/OpenAiChatController.getExistingMessages';

export default class OpenAiChat extends LightningElement {
    @api channelName = '/event/oai_sf_i__OpenAI_Event__e';
    subscription = {};
    userId = Id;

    userInput = '';
    chatResponse = '';
    chatId = '';
    chats = [];
    isLoading = false;

    connectedCallback() {
        this.registerErrorListener();
        this.subscribeToChannel();
        this.initializeChats();
    }

    subscribeToChannel() {
        const thisReference = this;

        const messageCallback = function (response) {
            thisReference.chatId = response.data.payload.oai_sf_i__Chat_Id__c;
            if(response.data.payload.oai_sf_i__User_Id__c === thisReference.userId && response.data.payload.oai_sf_i__Error__c === true){
                thisReference.chatResponse = 'An error occured. Please try again later.';
                thisReference.loading = false;
            }
            if(response.data.payload.oai_sf_i__User_Id__c === thisReference.userId && response.data.payload.oai_sf_i__Error__c === false){
                getExistingMessages({ chatId: response.data.payload.oai_sf_i__Chat_Id__c })
                    .then(result => {
                        var messages = JSON.parse(result);
                        thisReference.chatResponse = messages;
                        thisReference.isLoading = false;
                        thisReference.userInput = '';
                    })
                    .catch(error => {
                        thisReference.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error,
                                variant: 'error'
                            })
                        );
                    })
            }
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.subscription = response;
        });
    }

    registerErrorListener() {
        onError((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error'
                })
            );
        });
    }

    initializeChats() {
        getLastChats()
            .then(result => {
                this.chats = result.map(chat => {
                    return { label: chat.Name, value: chat.Id };
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
            });
    }

    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    handleChatChange(event) {
        this.chatId = event.detail.value;
        getExistingMessages({ chatId: this.chatId })
            .then(result => {
                var messages = JSON.parse(result);
                this.chatResponse = messages;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
            })
        
    }

    handleNewChat() {
        createNewChat()
            .then(result => {
                if(result === 'Error: You do not have access to create a new OpenAI Chat.'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                    return;
                }
                this.chatId = result;
                this.initializeChats();
                this.chatResponse = '';
                this.userInput = '';
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
            });
    }

    handleSubmit() {
        this.isLoading = true;
        chatWithOpenAI({ userInput: this.userInput, chatId: this.chatId })
            .then(result => {
                if(result === 'Chat is running in the background.' || result === 'It is taking longer than expected to get a response from OpenAI. The chat will continue to run in the background.'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Info',
                            message: result,
                            variant: 'info'
                        })
                    );
                    return;
                }
                var messages = JSON.parse(result);
                this.chatResponse = messages;
                this.userInput = '';
                this.isLoading = false;
            })
            .catch(error => {
                this.chatResponse = error;
                this.isLoading = false; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
            });
    }
}