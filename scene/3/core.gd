extends MarginContainer


@onready var crossroad = $VBox/Crossroad

var nexus = null
var maze = null
var outpost = null
var room = null


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	maze = nexus.sketch.maze
	
	var input = {}
	input.core = self
	crossroad.set_attributes(input)
	spaw_on_outpost()


func spaw_on_outpost() -> void:
	outpost = maze.outposts.get_children().pick_random()
	room = outpost.room
	maze.focus_on_room(room)
	crossroad.update_room()
