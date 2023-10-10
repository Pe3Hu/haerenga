extends MarginContainer


#@onready var pathways = $Pathways

var crossroad = null
var length = null
var destinations = {}
var departures = []


func set_attributes(input_: Dictionary) -> void:
	crossroad = input_.crossroad


func set_shortest_routes_based_on_dijkstra() -> void:
	destinations = {}
	departures = []
	var motion = crossroad.core.gameboard.get_token_stack_value("motion")
	var fuel = crossroad.core.gameboard.get_resource_stack_value("fuel")
	length = min(motion, fuel)
	
	if crossroad.origin != null:
		
		motion = crossroad.origin.get_token("input", "motion")
		
		if motion != null:
			length -= crossroad.origin.get_token_stack_value("input", "motion")
		
		motion = crossroad.origin.get_token("output", "motion")
		
		if motion != null:
			length += crossroad.origin.get_token_stack_value("output", "motion")
	
	add_destination(crossroad.room)
	compare_two_rooms(crossroad.room, crossroad.room)
	
	if length > 0:
		while !departures.is_empty():
			departures.sort_custom(func(a, b): return  destinations[a].length <  destinations[b].length)
			var departure = departures.pop_front()
			
			for door in departure.doors:
				var neighbor = departure.doors[door]
				
				if crossroad.core.intelligence.room.has(neighbor):
						add_destination(neighbor)
						compare_two_rooms(departure, neighbor)
		
		for destination in destinations.keys():
			if destinations[destination].parent == null:
				destinations.erase(destination)
	
#	print(length, "___", crossroad.room.index)
#	for destination in destinations:
#		print([length, destination.index, destinations[destination].parent.index, destinations[destination].length, crossroad.origin])


func add_destination(room_: Polygon2D) -> void:
	if !destinations.has(room_):
		destinations[room_] = {}
		destinations[room_].parent = null
		destinations[room_].length = length + 1


func compare_two_rooms(parent_: Polygon2D, child_: Polygon2D) -> void:
	if parent_ == crossroad.room and child_ == crossroad.room:
		destinations[child_].length = 0
		destinations[child_].parent = parent_
		departures.append(child_)
	else:
		var door = parent_.get_door_based_on_neighbor(child_)
		var l = {}
		l.old = destinations[child_].length
		l.new = destinations[parent_].length + door.length
		
		if l.new < l.old:
			destinations[child_].length = l.new
			destinations[child_].parent = parent_
			departures.append(child_)
	
	#print(parent_.index, child_.index, destinations[child_])
