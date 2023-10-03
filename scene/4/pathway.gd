extends MarginContainer


@onready var dooricon = $HBox/Door/Icon
@onready var doorlength = $HBox/Door/Length
@onready var roomicon = $HBox/Room/Icon
@onready var roomobstacle = $HBox/Room/Obstacle
@onready var roomrequirement = $HBox/Room/Requirement
@onready var roomcontent = $HBox/Room/Content
@onready var roomvalue = $HBox/Room/Value

var door = null
var rooms = {}


func set_attributes(input_: Dictionary) -> void:
	door = input_.door
	rooms.departure = input_.departure
	rooms.destination = input_.destination
	
	var input = {}
	input.type = "node"
	input.subtype = "door"
	dooricon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = door.length
	doorlength.set_attributes(input)
	
	input = {}
	input.type = "obstacle"
	input.subtype = rooms.destination.obstacle.subtype
	roomobstacle.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.obstacle.requirement
	roomrequirement.set_attributes(input)

	input = {}
	input.type = "content"
	input.subtype = rooms.destination.content.type
	roomcontent.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.content.value
	roomvalue.set_attributes(input)
