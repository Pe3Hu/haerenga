extends MarginContainer


@onready var title = $VBox/Title
@onready var tokens = $VBox/Tokens
@onready var definitely = $VBox/Tokens/Definitely
@onready var alternative = $VBox/Tokens/Alternative


var gameboard = null
var charge = {}
var toughness = {}


func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	title.text = input_.title
	
	fill_tokens()


func fill_tokens() -> void:
	var description = Global.dict.card[title.text]
	charge.limit = description.charge
	charge.current = charge.limit
	toughness.limit = description.toughness
	charge.current = charge.limit
	
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
