extends Line2D



var maze = null
var rooms = null


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	rooms = input_.rooms

	rooms.front().doors[rooms.back()] = self
	rooms.back().doors[rooms.front()] = self
	
	for room in rooms:
		add_point(room.position)
