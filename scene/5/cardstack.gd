extends MarginContainer


@onready var cards = $Cards

var gameboard = null


func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
