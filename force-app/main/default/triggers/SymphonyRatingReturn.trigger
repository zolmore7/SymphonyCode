trigger SymphonyRatingReturn on Sym_Rating_Return__e (after insert) {
    SymphonyTriggerHandler.SymphonyRatingReturn(trigger.new);
}