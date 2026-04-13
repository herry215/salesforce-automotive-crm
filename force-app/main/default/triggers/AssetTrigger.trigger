trigger AssetTrigger on Asset(
  before insert,
  before update,
  after insert,
  after update
) {
  AssetTriggerHandler.handle(Trigger.new, Trigger.old, Trigger.oldMap);
}
