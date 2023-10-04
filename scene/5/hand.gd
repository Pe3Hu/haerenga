extends MarginContainer


@onready var cards = $Cards

var capacity = {}
var gameboard = null


func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	
	capacity.current = 5
	capacity.limit = 10


func refill() -> void:
	while cards.get_child_count() < capacity.current:
		draw_card()


func draw_card() -> void:
	var card = gameboard.pull_card_from("deck")
	cards.add_child(card)
	

func apply() -> void:
	while cards.get_child_count() > 0:
		var card = cards.get_child(0)
		apply_card(card)
		discard_card(card)


func apply_card(card_: MarginContainer) -> void:
	for token in card_.definitely.get_children():
		var value = token.stack.get_number()
		gameboard.change_token_value(token.title.subtype, value)
	
	

func discard_card(card_: MarginContainer) -> void:
	cards.remove_child(card_)
	gameboard.discard.cards.add_child(card_)
