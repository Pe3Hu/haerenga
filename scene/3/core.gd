extends MarginContainer

@onready var gameboard = $HBox/Gameboard
@onready var crossroad = $HBox/Crossroad

var nexus = null
var maze = null
var outpost = null
var room = null
var intelligence = {}


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	maze = nexus.sketch.maze
	
	intelligence.room = []
	var input = {}
	input.core = self
	input.pathway = null
	crossroad.set_attributes(input)
	spaw_on_outpost()
	gameboard.set_attributes(input)
	crossroad.set_local_ambition()
	crossroad.update_continuations()


func spaw_on_outpost() -> void:
	outpost = maze.outposts.get_children().pick_random()
	room = outpost.room
	maze.focus_on_room(room)
	crossroad.set_room(room)
	get_outpost_intelligence()


func get_outpost_intelligence() -> void:
	get_intelligence(outpost.room, true)
		
	for door in outpost.room.doors:
		var room_ = outpost.room.doors[door]
		get_intelligence(room_, true)


func get_intelligence(room_: Polygon2D, free_: bool) -> void:
	intelligence.room.append(room_)
	
	if !free_:
		var resource = gameboard.get_resource("intelligence")
		resource.stack.change_number(-1)



func solution_availability_check(solution_: Dictionary) -> bool:
	for subtype in solution_:
		if !token_availability_check(subtype, solution_[subtype]):
			return false
	
	return true


func token_availability_check(subtype_: String, value_: int) -> bool:
	if subtype_ == "free":
		return true
	
	return gameboard.get_token_stack_value(subtype_) >= value_


func expedition_check_for_continuation(destination_: Dictionary) -> bool:
	
	return false
