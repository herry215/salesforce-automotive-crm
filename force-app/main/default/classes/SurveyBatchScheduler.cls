public class SurveyBatchScheduler implements Database.Batchable<SObject>, Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new SurveyBatchScheduler(), 200);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date sevenDaysAgo = Date.today().addDays(-7);
    return Database.getQueryLocator(
      [
        SELECT Id, VehicleId__c
        FROM ServiceAppointment__c
        WHERE Status__c = '완료' AND AppointmentDate__c <= :sevenDaysAgo
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<ServiceAppointment__c> scope
  ) {
    List<CustomerSurvey__c> surveysToInsert = new List<CustomerSurvey__c>();

    for (ServiceAppointment__c appt : scope) {
      CustomerSurvey__c survey = new CustomerSurvey__c();
      survey.AppointmentId__c = appt.Id;
      survey.SentDate__c = Date.today();
      survey.Status__c = '발송완료';
      surveysToInsert.add(survey);
    }

    if (!surveysToInsert.isEmpty()) {
      insert surveysToInsert;
    }
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('SurveyBatchScheduler 완료: ' + DateTime.now());
  }
}
