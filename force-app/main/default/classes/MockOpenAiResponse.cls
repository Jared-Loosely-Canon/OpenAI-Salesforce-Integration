/**
 * @description       : 
 * @author            : Jared Simpson
 * @group             : 
 * @last modified on  : 06-16-2023
 * @last modified by  : Jared Simpson
**/
global class MockOpenAiResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"id": "chatcmpl-9tbWns5pjt8OHlXg1jqfgpHHbY3jJ","object": "chat.completion","created": 1677649420,"model": "gpt-3.5-turbo","usage": {"prompt_tokens": 56,"completion_tokens": 25,"total_tokens": 81},"choices": [{"message": {"role": "assistant","content": "Hello, how can I assist you today?"},"finish_reason": "stop","index": 0}]}');
        return res;
    }
}