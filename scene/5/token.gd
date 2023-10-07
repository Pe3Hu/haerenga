extends MarginContainer


@onready var title = $HBox/Title
@onready var stack = $HBox/Stack


var proprietor = null


func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	
	var input = {}
	input.type = "token"
	input.subtype = input_.subtype
	title.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = input_.value
	stack.set_attributes(input)


func change_stack(value_: int) -> void:
	stack.change_number(value_)
