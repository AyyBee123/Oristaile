extends Node

@warning_ignore_start("unused_signal")
signal card_slot_changed(slot: Slot)
signal pin_added(pin: PinResource, pos: Vector2)
signal pin_removed(pin: PinResource)
signal gumball_added(pin: GumballResource, pos: Vector2)
signal gumball_removed(pin: GumballResource)
