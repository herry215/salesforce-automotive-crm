public with sharing class AssetDashboardController {
  @AuraEnabled(cacheable=true)
  public static List<Asset> getAssets() {
    return [
      SELECT Id, Name, SerialNumber, Status, Region__c, InstallDate, Product2Id
      FROM Asset
      ORDER BY CreatedDate DESC
      LIMIT 100
    ];
  }
}
