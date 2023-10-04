extends MarginContainer


@onready var title = $VBox/Title
@onready var tokens = $VBox/Tokens
@onready var definitely = $VBox/Tokens/Definitely
@onready var alternative = $VBox/Tokens/Alternative


var gameboard = null


func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	title.text = input_.title
	
	fill_tokens()


func fill_tokens() -> void:
	var description = Global.dict.card[title.text]
	
	for key in description.token:
		var input = {}
		input.proprietor = self
		input.token = description.token[key].name
		input.stack = description.token[key].value
		input.type = description.token[key].type
	
		var token = Global.scene.token.instantiate()
		get(description.token[key].type).add_child(token)
		token.set_attributes(input)
	
	
	for node in tokens.get_children():
		if node.get_child_count() > 0:
			node.visible = true
