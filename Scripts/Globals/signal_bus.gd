extends Node

@warning_ignore_start("unused_signal")
signal card_slot_changed(slot: Slot)
signal points_earned(points: float, card: Card, slot: Slot)
signal matched_suit(card: Card, slot: Slot)
signal card_accepted(card: Card, slot: Slot)
