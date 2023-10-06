extends MarginContainer


@onready var deck = $VBox/Cards/Deck
@onready var discard = $VBox/Cards/Discard
@onready var hand = $VBox/Cards/Hand
@onready var tokens = $VBox/Tokens
@onready var resources = $VBox/Resources


var core = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	input_.gameboard = self
	init_tokens()
	init_resources()
	init_starter_kit_cards()
	deck.set_attributes(input_)
	discard.set_attributes(input_)
	hand.set_attributes(input_)
	
	hand.refill()
	hand.apply()


func init_tokens() -> void:
	for subtype in Global.arr.token:
		var input = {}
		input.proprietor = self
		input.token = subtype
		input.stack = 0
	
		var token = Global.scene.token.instantiate()
		tokens.add_child(token)
		token.set_attributes(input)
		token.visible = false


func init_resources() -> void:
	for subtype in Global.arr.resource:
		var input = {}
		input.proprietor = self
		input.resource = subtype
		input.stack = 0
	
		var resource = Global.scene.resource.instantiate()
		resources.add_child(resource)
		resource.set_attributes(input)
		resource.visible = false


func init_starter_kit_cards() -> void:
	for title in Global.dict.card:
		for _i in Global.dict.card[title]["starter kit"]:
			var input = {}
			input.gameboard = self
			input.title = title
		
			var card = Global.scene.card.instantiate()
			discard.cards.add_child(card)
			card.set_attributes(input)


func refill_deck() -> void:
	var cards = []
	
	while discard.cards.get_child_count() > 0:
		var card = pull_card_from("discard")
		cards.append(card)
	
	cards.shuffle()
	
	for card in cards:
		deck.cards.add_child(card)


func pull_card_from(area_: String) -> Variant:
	var cards = get(area_).cards
	
	if cards.get_child_count() == 0 and area_ == "deck":
		refill_deck()
	
	if cards.get_child_count() > 0:
		var card = cards.get_child(0)
		cards.remove_child(card)
		return card
	
	print("error: empty area", area_)
	return null


func change_token_value(subtype_: String, value_: int) -> void:
	var token = get_token(subtype_)
	
	if token != null:
		token.stack.change_number(value_)
		
		if token.stack.get_number() > 0:
			token.visible = true
		else:
			token.visible = false


func get_token(subtype_: String) -> Variant:
	for token in tokens.get_children():
		if token.title.subtype == subtype_:
			return token
	
	print("error: no token", subtype_)
	return null


func get_token_stack_value(subtype_: String) -> Variant:
	var token = get_token(subtype_)
	return token.stack.get_number()


func get_resource(subtype_: String) -> Variant:
	for resource in resources.get_children():
		if resource.title.subtype == subtype_:
			return resource
	
	print("error: no resource", subtype_)
	return null


func get_resource_stack_value(subtype_: String) -> Variant:
	var resource = get_resource(subtype_)
	return resource.stack.get_number()
