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

    ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
    input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
    input.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';
    input.isPreview = false;

    Map<String, ConnectApi.WrappedValue> valueMap = new Map<String, ConnectApi.WrappedValue>();

    ConnectApi.WrappedValue feedbackValue = new ConnectApi.WrappedValue();
    feedbackValue.value = survey.Feedback__c;
    valueMap.put('Input:Feedback__c', feedbackValue);

    input.inputParams = valueMap;

    ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
      'Customer_Survey_Summary',
      input
    );

    return result.generations[0].text;
  }
}
