public with sharing class AssetTriggerHandler {
  public static void handle(
    List<Asset> newList,
    List<Asset> oldList,
    Map<Id, Asset> oldMap
  ) {
    if (Trigger.isAfter && Trigger.isUpdate) {
      handleAfterUpdate(newList, oldMap);
    }
  }

  private static void handleAfterUpdate(
    List<Asset> newList,
    Map<Id, Asset> oldMap
  ) {
    List<Task> tasksToInsert = new List<Task>();

    for (Asset a : newList) {
      Asset oldAsset = oldMap.get(a.Id);
      if (a.Status == '출고완료' && oldAsset.Status != '출고완료') {
        Task t = new Task();
        t.Subject = '[출고완료] 고객 인도 확인 요청 - ' + a.Name;
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.OwnerId = a.OwnerId;
        t.WhatId = a.Id;
        tasksToInsert.add(t);
      }
    }

    if (!tasksToInsert.isEmpty()) {
      insert tasksToInsert;
    }
  }
}
