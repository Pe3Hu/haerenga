extends MarginContainer

@onready var levelIcon = $VBox/HBox/Level/Icon
@onready var levelValue = $VBox/HBox/Level/Value
@onready var knowledgeIcon = $VBox/HBox/Knowledge/Icon
@onready var knowledgeValue = $VBox/HBox/Knowledge/Value
@onready var cards = $VBox/Cards

var core = null
var capacity = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	capacity = 10
	set_icons()


func set_icons() -> void:
	var input = {}
	input.type = "node"
	input.subtype = "level"
	levelIcon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = 1
	levelValue.set_attributes(input)
	
	input = {}
	input.type = "resource"
	input.subtype = "knowledge"
	knowledgeIcon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = pow(2, levelValue.get_number() + 3)
	knowledgeValue.set_attributes(input)
	
	refill_cards()


func refill_cards() -> void:
	while cards.get_child_count() < capacity:
		generate_card()
	
	var cards_ = []
	
	while cards.get_child_count() > 0:
		var card = cards.get_child(0)
		cards.remove_child(card)
		cards_.append(card)
	
	cards_.sort_custom(func(a, b): return a.price < b.price)
	
	for card in cards_:
		cards.add_child(card)


func generate_card() -> void:
	var options = Global.dict.loot.chance.level.rarity[levelValue.get_number()]
	var rarity = Global.get_random_key(options)
	var input = {}
	input.market = self
	input.index = Global.dict.card.rarity[rarity].pick_random()

	var card = Global.scene.card.instantiate()
	cards.add_child(card)
	card.set_attributes(input)


func progression() -> void:
	var knowledge = core.gameboard.get_resource_stack_value("knowledge")
	
	while knowledge > knowledgeValue.get_number():
		next_level()
		knowledge = core.gameboard.get_resource_stack_value("knowledge")
	
	reset()
	refill_cards()


func next_level() -> void:
	core.gameboard.change_resource_stack_value("knowledge", -knowledgeValue.get_number())
	levelValue.change_number(1)
	knowledgeValue.set_number(pow(2, levelValue.get_number() + 3))


func reset() -> void:
	while cards.get_child_count() > 0:
		var card = cards.get_child(0)
		cards.remove_child(card)
		card.queue_free()


func matchmaking() -> void:
	var datas = [null]
	var purchases = 0
	
	while !datas.is_empty():
		var minerals = core.gameboard.get_resource_stack_value("mineral")
		datas = []
	
		for _i in cards.get_child_count():
			var card = cards.get_child(_i)
			
			if card.price <= minerals:
				var data = {}
				#data.card = card
				data.slot = _i
				data.weight = 0
				
				for token in card.tokens.get_children():
					var subtype = token.title.subtype
					
					if core.empowerment.has(subtype):
						data.weight += core.empowerment[subtype] * token.stack.get_number() * card.get_current_charge()
				
				datas.append(data)
		
		if !datas.is_empty():
			datas.sort_custom(func(a, b): return a.weight > b.weight)
			var slot = datas.front().slot
			core.buy_market_card(slot)
			datas = [null]
			purchases += 1
		else:
			if purchases == 0:
				if !core.empowerment.has("extraction"):
					core.empowerment["extraction"] = 0
				
				core.empowerment["extraction"] += 5
