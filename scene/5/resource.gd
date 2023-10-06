extends MarginContainer


@onready var title = $HBox/Title
@onready var stack = $HBox/Stack


var proprietor = null


func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	
	var input = {}
	input.type = "resource"
	input.subtype = input_.resource
	title.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = input_.stack
	stack.set_attributes(input)


func change_stack(value_: int) -> void:
	stack.change_number(value_)
