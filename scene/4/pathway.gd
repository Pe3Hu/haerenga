extends MarginContainer


@onready var destination = $HBox/Destination
@onready var length = $HBox/Length


var door = null
var rooms = {}


func set_attributes(input_: Dictionary) -> void:
	door = input_.door
	rooms.departure = input_.departure
	rooms.destination = input_.destination
	
	var input = {}
	input.type = "number"
	input.subtype = rooms.destination.index
	destination.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = door.length
	length.set_attributes(input)