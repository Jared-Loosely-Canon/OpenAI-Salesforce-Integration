/**
 * @description       : 
 * @author            : Jared Simpson
 * @group             : 
 * @last modified on  : 06-15-2023
 * @last modified by  : Jared Simpson
**/
public class OpenAiChatWrapper {
    public String id;
    public Integer created;
    public String model;
    public Usage usage;
    public List<Choices> choices;
    
    public class Usage {
        public Integer prompt_tokens;
        public Integer completion_tokens;
        public Integer total_tokens;
    }
    
    public class Choices {
        public Message message;
        public String finish_reason;
        public Integer index;
    }

    public class Message {
        public String role;
        public String content;
    }
    
    // Function to parse the JSON string into this class
    public static OpenAiChatWrapper parse(String jsonString) {
        return (OpenAiChatWrapper) System.JSON.deserialize(jsonString, OpenAiChatWrapper.class);
    }
}