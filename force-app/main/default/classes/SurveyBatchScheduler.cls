public with sharing class SurveyBatchScheduler implements Database.Batchable<sObject>, Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new SurveyBatchScheduler(), 200);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date sevenDaysAgo = Date.today().addDays(-7);
    return Database.getQueryLocator(
      [
        SELECT Id, Status__c, SentDate__c
        FROM CustomerSurvey__c
        WHERE Status__c = '발송대기' AND CreatedDate <= :sevenDaysAgo
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<CustomerSurvey__c> scope
  ) {
    List<CustomerSurvey__c> toUpdate = new List<CustomerSurvey__c>();
    for (CustomerSurvey__c survey : scope) {
      survey.Status__c = '발송완료';
      survey.SentDate__c = Date.today();
      toUpdate.add(survey);
    }
    if (!toUpdate.isEmpty()) {
      update toUpdate;
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}
