extends MarginContainer


@onready var destination = $HBox/Destination
@onready var length = $HBox/Length


var door = null
var rooms = {}


func set_attributes(input_: Dictionary) -> void:
	door = input_.door
	rooms.departure = input_.departure
	rooms.destination = input_.destination
	destination.set_number(rooms.destination.index)
	length.set_number(door.length)
