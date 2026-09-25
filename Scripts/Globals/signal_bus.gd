extends Node

@warning_ignore_start("unused_signal")
signal card_slot_changed(slot: Slot)
signal points_earned(points: float, card: CardResource, slot: Slot)
signal matched_suit(card: CardResource, slot: Slot)
signal card_accepted(card: CardResource, slot: Slot)
