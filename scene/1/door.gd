extends Line2D



var maze = null
var rooms = null
var type = null
var icon = null
var index = null
var length = 0
var ring = {}
var center = Vector2()
var intersections = []


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	rooms = input_.rooms
	type = input_.type
	index = Global.num.index.door
	Global.num.index.door += 1
	connect_rooms()
	
	var input = {}
	input.type = "number"
	input.subtype = index
	
	icon = Global.scene.icon.instantiate()
	maze.idoor.add_child(icon)
	icon.set_attributes(input)
	icon.position = center
	
	#icon.position.x -= maze.get("theme_override_constants/margin_left")
	#icon.position.y -= maze.get("theme_override_constants/margin_top")


func connect_rooms() -> void:
	rooms.front().doors[self] = rooms.back()
	rooms.back().doors[self] = rooms.front()
	
	for room in rooms:
		add_point(room.position)
		center += room.position
	
	center /= rooms.size()
	ring.begin = min(rooms.back().ring, rooms.front().ring)
	ring.end = max(rooms.back().ring, rooms.front().ring)


func collapse() -> void:
	rooms.front().doors.erase(self)
	rooms.back().doors.erase(self)
	
	maze.doors.remove_child(self)
	maze.idoor.remove_child(icon)
	queue_free()


func get_another_room(room_: Polygon2D) -> Polygon2D:
	var rooms_ = []
	rooms_.append_array(rooms)
	rooms_.erase(room_)
	return rooms_.front()


func add_length() -> void:
	roll_length()
	var input = {}
	input.type = "number"
	input.subtype = length
	
	var icon_ = Global.scene.icon.instantiate()
	maze.ilength.add_child(icon_)
	icon_.set_attributes(input)
	icon_.position = center


func roll_length() -> void:
	var sector = 0.0
	
	for room in rooms:
		sector += room.sector
	
	sector /= rooms.size()
	Global.rng.randomize()
	length = Global.rng.randi_range(Global.dict.door.length.sector[sector].min, Global.dict.door.length.sector[sector].max)
	
