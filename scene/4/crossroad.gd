extends MarginContainer


@onready var tree = $Tree
@onready var pathways = $Pathways

var core = null
var maze = null
var room = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	maze = core.maze
	
	var input = {}
	input.crossroad = self
	tree.set_attributes(input)


func set_room(room_: Polygon2D) -> void:
	room = room_
	reset_pathways()


func reset_pathways() -> void:
	for pathway in pathways.get_children():
		pathways.remove_child(pathway)
		pathway.queue_free()


func fill_pathways() -> void:
	tree.set_shortest_routes_based_on_dijkstra()
	var destinations = tree.destinations.keys()
	destinations.sort_custom(func(a, b): return  tree.destinations[a].length <  tree.destinations[b].length)
	
	for destination in destinations:
		var input = {}
		input.length = tree.destinations[destination].length
		input.departure = room
		input.destination = destination
		
		var pathway = Global.scene.pathway.instantiate()
		pathways.add_child(pathway)
		pathway.set_attributes(input)
		#pathway.add_tokens("input", "motion", input.length)


func get_pathway(destination_: Polygon2D) -> Variant:
	for pathway in pathways.get_children():
		if pathway.rooms.destination == destination_:
			return pathway
	
	return null
