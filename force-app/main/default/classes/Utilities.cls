/**
 * @description       : Useful utilities for app development
 * @author            : Jared Simpson
 * @group             : 
 * @last modified on  : 06-16-2023
 * @last modified by  : Jared Simpson
**/
public with sharing class Utilities {
    static final String[] fieldsToSkip = new String[]{'Id', 'Name', 'CreatedDate', 'LastModifiedDate', 'LastModifiedById', 'SystemModstamp', 'IsDeleted', 'IsConverted'};

    /**
    * @description: Checks if every field on an object is accessible and createable to the current user
    * @usage: Pass a single SObject with the necessary fields that you intend to create it with. 
    *         Generally call this right before you perform an insert
    * @author Jared Simpson | 06-16-2023 
    * @param obj SObject to check
    * @return Boolean 
    **/
    public static Boolean checkCreateFieldLevelSecurity(SObject obj){
        Schema.DescribeSObjectResult objDescribe = obj.getSObjectType().getDescribe();

        // Get the field map for the fields actually populated in the SObject instance
        Map<String, Object> populatedFieldMap = obj.getPopulatedFieldsAsMap();

        // Loop through each populated field in the SObject
        for (String fieldName : populatedFieldMap.keySet()) {
            if (fieldsToSkip.contains(fieldName) || fieldName.endsWith('__r')) {
                continue;
            }
            // Get the schema information for the field
            Schema.SObjectField sField = objDescribe.fields.getMap().get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = sField.getDescribe();

            // Check if the field is createable and accessible
            // If not, return false
            if (!(fieldDescribe.isCreateable() && fieldDescribe.isAccessible())) {
                return false;
            }
        }

        // If all checks passed, return true
        return true;
    }

    /**
    * @description: Checks if every field on an object is accessible and updateable to the current user
    * @usage: Pass a single SObject with the necessary fields that you intend to create it with. 
    *         Generally call this right before you perform an update
    * @author Jared Simpson | 06-16-2023 
    * @param obj 
    * @return Boolean 
    **/
    public static Boolean checkUpdateFieldLevelSecurity(SObject obj){
        Schema.DescribeSObjectResult objDescribe = obj.getSObjectType().getDescribe();

        // Get the field map for the fields actually populated in the SObject instance
        Map<String, Object> populatedFieldMap = obj.getPopulatedFieldsAsMap();

        // Loop through each populated field in the SObject
        for (String fieldName : populatedFieldMap.keySet()) {
            if (fieldsToSkip.contains(fieldName) || fieldName.endsWith('__r')) {
                continue;
            }
            // Get the schema information for the field
            Schema.SObjectField sField = objDescribe.fields.getMap().get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = sField.getDescribe();

            // Check if the field is createable, updateable, and accessible
            // If not, return false
            if (!(fieldDescribe.isUpdateable() && fieldDescribe.isAccessible())) {
                return false;
            }
        }
        // If all checks passed, return true
        return true;
    }
}