extends MarginContainer

@onready var gameboard = $VBox/Gameboard
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
	gameboard.set_attributes(input)
	set_ambition()


func spaw_on_outpost() -> void:
	outpost = maze.outposts.get_children().pick_random()
	room = outpost.room
	maze.focus_on_room(room)
	crossroad.update_room()


func set_ambition() -> void:
	var destinations = {}
	
	for pathway in crossroad.pathways.get_children():
		var destination = pathway.rooms.destination
		destinations[destination] = []
		var solutions = []
		
		if destination.obstacle.subtype != "empty":
			solutions = destination.obstacle.get_solutions()
		else:
			solutions.append({})
		
		for solution in solutions:
			if !solution.has("motion"):
				solution["motion"] = 0
			
			solution["motion"] += pathway.doorlength.get_number()
			
			#print(solution)
			
			if solution_availability_check(solution):
				destinations[destination].append(solution)
		
	
	print(destinations)


func solution_availability_check(solution_: Dictionary) -> bool:
	for subtype in solution_:
		if !token_availability_check(subtype, solution_[subtype]):
			return false
	
	return true


func token_availability_check(subtype_: String, value_: int) -> bool:
	return gameboard.get_token_stack_value(subtype_) >= value_
