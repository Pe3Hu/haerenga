extends MarginContainer


@onready var available = $VBox/Cards/Available
@onready var discharged = $VBox/Cards/Discharged
@onready var broken = $VBox/Cards/Broken
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
	available.set_attributes(input_)
	discharged.set_attributes(input_)
	broken.set_attributes(input_)
	hand.set_attributes(input_)
	
	hand.refill()
	hand.apply()


func init_tokens() -> void:
	for subtype in Global.arr.token:
		var input = {}
		input.proprietor = self
		input.subtype = subtype
		input.value = 0
	
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
		#resource.visible = false
	
	change_resource_stack_value("fuel", 30)


func init_starter_kit_cards() -> void:
	for title in Global.dict.card:
		for _i in Global.dict.card[title]["starter kit"]:
			var input = {}
			input.gameboard = self
			input.title = title
		
			var card = Global.scene.card.instantiate()
			available.cards.add_child(card)
			card.set_attributes(input)
	
	reshuffle_available()


func reshuffle_available() -> void:
	var cards = []
	
	while available.cards.get_child_count() > 0:
		var card = pull_card()
		cards.append(card)
	
	cards.shuffle()
	
	for card in cards:
		available.cards.add_child(card)


func pull_card() -> Variant:
	var cards = available.cards
	
	if cards.get_child_count() > 0:
		var card = cards.get_children().pick_random()
		cards.remove_child(card)
		return card
	
	print("error: empty available")
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


func change_resource_stack_value(subtype_: String, value_: int) -> void:
	var resource = get_resource(subtype_)
	resource.stack.change_number(value_)
