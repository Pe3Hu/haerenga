extends Line2D



var maze = null
var rooms = null
var type = null
var index = null


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	rooms = input_.rooms
	type = input_.type
	index = Global.num.index.door
	Global.num.index.door += 1
	connect_rooms()
	


func connect_rooms() -> void:
	rooms.front().doors[self] = rooms.back()
	rooms.back().doors[self] = rooms.front()
	
	for room in rooms:
		add_point(room.position)


func collapse() -> void:
	rooms.front().doors.erase(self)
	rooms.back().doors.erase(self)
	
	maze.doors.remove_child(self)
	#queue_free()

