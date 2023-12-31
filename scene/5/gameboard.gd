extends MarginContainer


@onready var available = $VBox/Cards/Available
@onready var discharged = $VBox/Cards/Discharged
@onready var broken = $VBox/Cards/Broken
@onready var hand = $VBox/Cards/Hand
@onready var tokens = $VBox/Tokens
@onready var resources = $VBox/Resources
@onready var crowns = $VBox/Crowns

var core = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	input_.gameboard = self
	init_tokens()
	init_resources()
	init_crowns()
	init_starter_kit_cards()
	available.set_attributes(input_)
	discharged.set_attributes(input_)
	broken.set_attributes(input_)
	hand.set_attributes(input_)
	
	#next_turn()


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
	var subtypes = ["energy", "spares"]
	subtypes.append_array(Global.arr.resource)
	
	for subtype in subtypes:
		var input = {}
		input.proprietor = self
		input.resource = subtype
		input.stack = 0
	
		var resource = Global.scene.resource.instantiate()
		resources.add_child(resource)
		resource.set_attributes(input)
		resource.visible = Global.arr.resource.has(subtype)


func init_crowns() -> void:
	for cogs in 6:
		var input = {}
		input.proprietor = self
		input.cogs = str(cogs)
		input.value = 0
	
		var crown = Global.scene.crown.instantiate()
		crowns.add_child(crown)
		crown.set_attributes(input)


func init_starter_kit_cards() -> void:
	for index in Global.dict.card.starte_kit:
		for _i in Global.dict.card.starte_kit[index]:
			var input = {}
			input.market = null
			input.index = index
		
			var card = Global.scene.card.instantiate()
			core.market.cards.add_child(card)
			card.set_attributes(input)
			card.price = 0
	
	while core.market.cards.get_child_count() > 0:
		var index = 0
		core.buy_market_card(index)
	
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


func get_crown(subtype_: String) -> Variant:
	for crown in crowns.get_children():
		if crown.cogs.subtype == subtype_:
			return crown
	
	print("error: no crown", subtype_)
	return null


func get_crown_stack_value(subtype_: String) -> Variant:
	var crown = get_resource(subtype_)
	return crown.stack.get_number()


func change_crown_stack_value(subtype_: String, value_: int) -> void:
	var crown = get_crown(subtype_)
	crown.change_stack(value_)


func recharge_card() -> void:
	var options = []
	options.append_array(discharged.cards.get_children())
	
	if options.is_empty():
		for card in available.cards.get_children():
			if card.charge.current < card.charge.limit:
				options.append(card)
	
	if !options.is_empty():
		var card = options.pick_random()
		card.recharge()


func overload_card() -> void:
	var options = []
	options.append_array(available.cards.get_children())
	
	if !options.is_empty():
		var card = options.pick_random()
		card.overload()


func repair_card() -> void:
	var options = []
	
	options.append_array(broken.cards.get_children())
	
	if options.is_empty():
		for card in available.cards.get_children():
			if card.toughness.current < card.toughness.limit:
				options.append(card)
	
	if !options.is_empty():
		var card = options.pick_random()
		card.recharge()


func breakage_card() -> void:
	var options = []
	options.append_array(available.cards.get_children())
	
	if !options.is_empty():
		var card = options.pick_random()
		card.overload()


func next_turn() -> void:
	#reset_resources()
	
	hand.refill()
	hand.apply()


func reset_tokens() -> void:
	for token in tokens.get_children():
		token.stack.set_number(0)
		token.visible = false
		#tokens.remove_child(token)
		#token.queue_free()


func reset_resources() -> void:
	for resource in resources.get_children():
		resource.stack.set_number(0)
		#resources.remove_child(resource)
		#resource.queue_free()


func repair_all_cards() -> void:
	var spares = 0
	var cards = []
	cards.append_array(available.cards.get_children())
	cards.append_array(discharged.cards.get_children())
	cards.append_array(broken.cards.get_children())
	
	for card in cards:
		while card.toughness.current < card.toughness.limit: 
			card.repair()
			spares += 1
	
	print("spares: ", spares)


func recharge_all_cards() -> void:
	var energy = 0
	var cards = []
	cards.append_array(available.cards.get_children())
	cards.append_array(discharged.cards.get_children())
	
	for card in cards:
		while card.charge.current < card.charge.limit: 
			card.recharge()
			energy += 1
	
	print("energy: ", energy)


func get_tokens_as_dict() -> Dictionary:
	var result = {}
	result["motion"] = 0
	
	for token in tokens.get_children():
		var subtype = token.title.subtype
		result[subtype] = core.gameboard.get_token_stack_value(subtype)
	
		if result[subtype] == 0 and subtype != "motion":
			result.erase(subtype)
	
	return result

