extends MarginContainer

@onready var level = $VBox/Level 
@onready var cards = $VBox/Cards

var nexus = null
var capacity = null


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	capacity = 10
	
	var input = {}
	input.type = "number"
	input.subtype = 1
	level.set_attributes(input)
	
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
	var options = Global.dict.loot.chance.level.rarity[level.get_number()]
	var rarity = Global.get_random_key(options)
	var input = {}
	input.market = self
	input.index = Global.dict.card.rarity[rarity].pick_random()

	var card = Global.scene.card.instantiate()
	cards.add_child(card)
	card.set_attributes(input)
