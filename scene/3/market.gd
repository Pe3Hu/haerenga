extends MarginContainer

@onready var level = $VBox/Level 
@onready var cards = $VBox/Cards

var nexus = null
var capacity = null


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	capacity = 6
	
	var input = {}
	input.type = "number"
	input.subtype = 12
	level.set_attributes(input)
	
	refill_cards()


func refill_cards() -> void:
	while cards.get_child_count() < capacity:
		generate_card()


func generate_card() -> void:
	var options = Global.dict.loot.chance.level.rarity[level.get_number()]
	var rarity = Global.get_random_key(options)
	var input = {}
	input.market = self
	input.index = Global.dict.card.rarity[rarity].pick_random()
	input.price = 0

	var card = Global.scene.card.instantiate()
	cards.add_child(card)
	card.set_attributes(input)
