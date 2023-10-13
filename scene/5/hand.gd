extends MarginContainer


@onready var cards = $Cards

var capacity = {}
var gameboard = null


func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	
	capacity.current = 5
	capacity.limit = 10


func refill() -> void:
	gameboard.reshuffle_available()
	while cards.get_child_count() < capacity.current and gameboard.available.cards.get_child_count() > 0:
		draw_card()


func draw_card() -> void:
	var card = gameboard.pull_card()
	#print(card.title.text)
	cards.add_child(card)


func apply() -> void:
	while cards.get_child_count() > 0:
		var card = cards.get_child(0)
		apply_card(card)
		discard_card(card)


func apply_card(card_: MarginContainer) -> void:
	for token in card_.tokens.get_children():
		var value = token.stack.get_number()
		gameboard.change_token_value(token.title.subtype, value)


func discard_card(card_: MarginContainer) -> void:
	cards.remove_child(card_)
	card_.charge.current -= 1
	
	if card_.charge.current > 0:
		gameboard.available.cards.add_child(card_)
	else:
		gameboard.discharged.cards.add_child(card_)
		card_.area = gameboard.discharged
