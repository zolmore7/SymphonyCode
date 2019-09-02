trigger SymphonyMessages on Sym_Message_Bus__e (after insert) {
    SymphonyTriggerHandler.SymphonyIIBMessage(trigger.new);
}