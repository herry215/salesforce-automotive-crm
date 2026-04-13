public with sharing class AiSummaryController {
  @AuraEnabled(cacheable=false)
  public static String getSurveySummary(Id surveyId) {
    CustomerSurvey__c survey = [
      SELECT Id, Feedback__c, Score__c, Status__c
      FROM CustomerSurvey__c
      WHERE Id = :surveyId
      LIMIT 1
    ];

    if (survey.Feedback__c == null) {
      return '고객 의견이 아직 없습니다.';
    }

    Map<String, String> recordIdMap = new Map<String, String>();
    recordIdMap.put('id', surveyId);

    ConnectApi.WrappedValue wrappedRecord = new ConnectApi.WrappedValue();
    wrappedRecord.value = recordIdMap;

    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
    inputParams.put('Input:customerSurvey', wrappedRecord);

    ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
    promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
    promptInput.additionalConfig.applicationName = 'PromptBuilderPreview';
    promptInput.additionalConfig.numGenerations = 1;
    promptInput.isPreview = false;
    promptInput.inputParams = inputParams;

    ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
      'Customer_Survey_Summary_Flex',
      promptInput
    );

    return result.generations[0].text;
  }
}
