extends MarginContainer


@onready var title = $VBox/Title
@onready var tokens = $VBox/Tokens
@onready var definitely = $VBox/Tokens/Definitely
@onready var alternative = $VBox/Tokens/Alternative


var area = null
var gameboard = null
var charge = {}
var toughness = {}


func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	area = gameboard.available
	title.text = input_.title
	
	fill_tokens()


func fill_tokens() -> void:
	var description = Global.dict.card[title.text]
	charge.limit = description.charge
	charge.current = charge.limit
	toughness.limit = description.toughness
	toughness.current = toughness.limit
	
	for key in description.token:
		var input = {}
		input.proprietor = self
		input.subtype = description.token[key].subtype
		input.value = description.token[key].value
		input.definiteness = description.token[key].definiteness
	
		var token = Global.scene.token.instantiate()
		get(description.token[key].definiteness).add_child(token)
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
	print(area.name, charge, area.name)


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
