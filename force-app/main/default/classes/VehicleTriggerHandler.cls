public class VehicleTriggerHandler {
    public static void handle(
        List<Vehicle__c> newList,
        List<Vehicle__c> oldList,
        System.TriggerOperation operationType
    ) {
        if (operationType == System.TriggerOperation.AFTER_UPDATE) {
            handleAfterUpdate(newList, oldList);
        }
    }

    private static void handleAfterUpdate(
        List<Vehicle__c> newList,
        List<Vehicle__c> oldList
    ) {
        Map<Id, Vehicle__c> oldMap = new Map<Id, Vehicle__c>(oldList);
        List<Task> tasksToInsert = new List<Task>();

        for (Vehicle__c v : newList) {
            Vehicle__c oldVehicle = oldMap.get(v.Id);
            if (v.Status__c == '출고완료' && oldVehicle.Status__c != '출고완료') {
                Task t = new Task();
                t.Subject = '[출고완료] ' + v.Name + ' 출고 후 고객 만족도 확인';
                t.WhatId = v.Id;
                t.OwnerId = v.OwnerId;
                t.ActivityDate = Date.today().addDays(3);
                t.Priority = 'Normal';
                t.Status = 'Not Started';
                tasksToInsert.add(t);
            }
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}