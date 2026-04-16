@isTest
public class AssetTriggerHandlerTest {
  @TestSetup
  static void setupTestData() {
    Account acc = new Account(Name = '테스트 고객사');
    insert acc;

    Contact con = new Contact(
      FirstName = '테스트',
      LastName = '고객',
      AccountId = acc.Id
    );
    insert con;

    Product2 prod = new Product2(
      Name = '아이오닉6',
      ProductCode = 'IONIQ6',
      IsActive = true
    );
    insert prod;

    List<Asset> assets = new List<Asset>{
      new Asset(
        Name = '아이오닉6-TEST001',
        SerialNumber = 'TESTVIN00000001',
        Status = '재고',
        AccountId = acc.Id,
        ContactId = con.Id,
        Product2Id = prod.Id,
        Region__c = '태국'
      ),
      new Asset(
        Name = '아이오닉6-TEST002',
        SerialNumber = 'TESTVIN00000002',
        Status = '계약',
        AccountId = acc.Id,
        ContactId = con.Id,
        Product2Id = prod.Id,
        Region__c = '인도네시아'
      )
    };
    insert assets;
  }

  @isTest
  static void testTaskCreatedOnDeliveryComplete() {
    Asset a = [
      SELECT Id, Status
      FROM Asset
      WHERE SerialNumber = 'TESTVIN00000001'
      LIMIT 1
    ];

    Test.startTest();
    a.Status = '출고완료';
    a.InstallDate = Date.today();
    update a;
    Test.stopTest();

    List<Task> tasks = [
      SELECT Id, Subject, WhatId
      FROM Task
      WHERE WhatId = :a.Id
    ];
    System.assertEquals(
      1,
      tasks.size(),
      '출고완료 시 Task 1건 생성되어야 합니다.'
    );
    System.assert(
      tasks[0].Subject.contains('[출고완료]'),
      'Task Subject에 [출고완료] 포함되어야 합니다.'
    );
  }

  @isTest
  static void testNoTaskWhenStatusNotDelivered() {
    Asset a = [
      SELECT Id, Status
      FROM Asset
      WHERE SerialNumber = 'TESTVIN00000002'
      LIMIT 1
    ];

    Test.startTest();
    a.Status = '재고';
    update a;
    Test.stopTest();

    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :a.Id];
    System.assertEquals(
      0,
      tasks.size(),
      '출고완료가 아니면 Task 생성 안됩니다.'
    );
  }

  @isTest
  static void testBulkUpdate() {
    List<Asset> assets = [SELECT Id, Status FROM Asset];

    Test.startTest();
    for (Asset a : assets) {
      a.Status = '출고완료';
      a.InstallDate = Date.today();
    }
    update assets;
    Test.stopTest();

    Set<Id> assetIds = new Map<Id, Asset>(assets).keySet();
    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :assetIds];
    System.assertEquals(
      assets.size(),
      tasks.size(),
      '벌크 업데이트 시 Asset 수만큼 Task 생성되어야 합니다.'
    );
  }
}
