import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, onError, } from 'lightning/empApi';
import Id from '@salesforce/user/Id';


import chatWithOpenAI from '@salesforce/apex/OpenAiChatController.chatWithOpenAI';
import getLastChats from '@salesforce/apex/OpenAiChatController.getLastChats';
import createNewChat from '@salesforce/apex/OpenAiChatController.createNewChat';
import getExistingMessages from '@salesforce/apex/OpenAiChatController.getExistingMessages';

export default class OpenAiChat extends LightningElement {
    userId = Id;

    userInput = '';
    chatResponse = '';
    chatId = '';
    chats = [];
    isLoading = false;

    connectedCallback() {
        this.initializeChats();
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