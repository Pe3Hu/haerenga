extends MarginContainer


@onready var chargeIcon = $VBox/Charge/Icon
@onready var chargeValue = $VBox/Charge/Value
@onready var toughnessIcon = $VBox/Toughness/Icon
@onready var toughnessValue = $VBox/Toughness/Value
@onready var bg = $BG
@onready var index = $VBox/Index
@onready var tokens = $VBox/Tokens


var area = null
var gameboard = null
var market = null
var price = null
var rarity = null
var charge = {}
var toughness = {}


func set_attributes(input_: Dictionary) -> void:
	var description = Global.dict.card.index[input_.index]
	market = input_.market
	rarity = description.rarity
	price = input_.price
	charge.limit = description.limit.charge
	charge.current = charge.limit
	toughness.limit = description.limit.toughness
	toughness.current = toughness.limit
	index.text = str(input_.index)
	
	set_icons()
	fill_tokens()

func set_icons() -> void:
	var style = StyleBoxFlat.new()
	bg.set("theme_override_styles/panel", style)
	style.bg_color = Global.color.rarity[rarity]
	
	var input = {}
	input.type = "resource"
	input.subtype = "energy"
	chargeIcon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = charge.current
	chargeValue.set_attributes(input)
	
	input = {}
	input.type = "resource"
	input.subtype = "spares"
	toughnessIcon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = toughness.current
	toughnessValue.set_attributes(input)


func fill_tokens() -> void:
	var description = Global.dict.card.index[int(index.text)]
	charge.limit = description.limit.charge
	charge.current = charge.limit
	toughness.limit = description.limit.toughness
	toughness.current = toughness.limit
	
	for subtype in description.token:
		var input = {}
		input.proprietor = self
		input.subtype = subtype
		input.value = description.token[subtype]
	
		var token = Global.scene.token.instantiate()
		tokens.add_child(token)
		token.set_attributes(input)
	
	for node in tokens.get_children():
		if node.get_child_count() > 0:
			node.visible = true


func recharge() -> void:
	charge.current += 1
	
	if charge.current == charge.limit and area == gameboard.discharged:
		gameboard.discharged.cards.remove_child(self)
		gameboard.available.cards.add_child(self)
		area = gameboard.available
	#print(area.name, charge, area.name)


func overload() -> void:
	charge.current -= 1
	
	if charge.current == 0 and area == gameboard.available:
		gameboard.available.cards.remove_child(self)
		gameboard.discharged.cards.add_child(self)
		area = gameboard.discharged


func repair() -> void:
	toughness.current += 1
	
	if toughness.current > 0 and area == gameboard.broken:
		gameboard.broken.cards.remove_child(self)
		gameboard.available.cards.add_child(self)
		area = gameboard.available


func breakage() -> void:
	toughness.current -= 1
	
	if toughness.current == 0 and area == gameboard.available:
		gameboard.available.cards.add_child(self)
		gameboard.broken.cards.remove_child(self)
		area = gameboard.broken
