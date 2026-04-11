public with sharing class VehicleDashboardController {
  @AuraEnabled(cacheable=true)
  public static List<Vehicle__c> getVehicles() {
    return [
      SELECT Id, Name, Model__c, VIN__c, Year__c, Status__c, DeliveryDate__c
      FROM Vehicle__c
      ORDER BY CreatedDate DESC
      LIMIT 50
    ];
  }
}
