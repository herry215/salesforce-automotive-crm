@isTest
public class VehicleTriggerHandlerTest {
  @TestSetup
  static void setupTestData() {
    Account acc = new Account();
    acc.Name = '테스트 고객사';
    acc.Phone = '010-0000-0000';
    insert acc;

    List<Vehicle__c> vehicles = new List<Vehicle__c>();

    Vehicle__c v1 = new Vehicle__c();
    v1.Name = '테스트차량-001';
    v1.VIN__c = 'TESTVIN000000001';
    v1.Model__c = '아이오닉6';
    v1.Year__c = 2024;
    v1.Status__c = '재고';
    v1.AccountId__c = acc.Id;
    vehicles.add(v1);

    Vehicle__c v2 = new Vehicle__c();
    v2.Name = '테스트차량-002';
    v2.VIN__c = 'TESTVIN000000002';
    v2.Model__c = '쏘나타';
    v2.Year__c = 2023;
    v2.Status__c = '계약';
    v2.AccountId__c = acc.Id;
    vehicles.add(v2);

    insert vehicles;
  }

  @isTest
  static void testTaskCreatedOnDeliveryComplete() {
    Vehicle__c v = [
      SELECT Id, Status__c
      FROM Vehicle__c
      WHERE VIN__c = 'TESTVIN00000000001'
      LIMIT 1
    ];

    Test.startTest();
    v.Status__c = '출고완료';
    v.DeliveryDate__c = Date.today();
    update v;
    Test.stopTest();

    List<Task> tasks = [
      SELECT Id, Subject, WhatId
      FROM Task
      WHERE WhatId = :v.Id
    ];
    System.assertEquals(
      1,
      tasks.size(),
      '출고완료 시 Task가 1건 생성되어야 합니다.'
    );
    System.assert(
      tasks[0].Subject.contains('[출고완료]'),
      'Task Subject에 [출고완료] 포함되어야 합니다.'
    );
  }

  @isTest
  static void testNoTaskWhenStatusNotChanged() {
    Vehicle__c v = [
      SELECT Id, Status__c
      FROM Vehicle__c
      WHERE VIN__c = 'TESTVIN00000000002'
      LIMIT 1
    ];

    Test.startTest();
    v.Status__c = '출고완료';
    v.DeliveryDate__c = Date.today();
    update v;

    v.Status__c = '출고완료';
    update v;
    Test.stopTest();

    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :v.Id];
    System.assertEquals(
      1,
      tasks.size(),
      '이미 출고완료 상태에서 재업데이트 시 Task가 추가 생성되면 안됩니다.'
    );
  }

  @isTest
  static void testBulkUpdate() {
    List<Vehicle__c> vehicles = [SELECT Id, Status__c FROM Vehicle__c];

    Test.startTest();
    for (Vehicle__c v : vehicles) {
      v.Status__c = '출고완료';
      v.DeliveryDate__c = Date.today();
    }
    update vehicles;
    Test.stopTest();

    Set<Id> vehicleIds = new Map<Id, Vehicle__c>(vehicles).keySet();
    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :vehicleIds];
    System.assertEquals(
      vehicles.size(),
      tasks.size(),
      '벌크 업데이트 시 차량 수만큼 Task가 생성되어야 합니다.'
    );
  }
}
