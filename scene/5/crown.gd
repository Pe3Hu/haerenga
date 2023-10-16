extends MarginContainer


@onready var cogs = $HBox/Cogs
@onready var stack = $HBox/Stack


var proprietor = null


func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	
	var input = {}
	input.type = "crown"
	input.subtype = input_.cogs
	cogs.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = input_.value
	stack.set_attributes(input)
	visible = false


func change_stack(value_: int) -> void:
	stack.change_number(value_)
	visible = stack.get_number() > 0
