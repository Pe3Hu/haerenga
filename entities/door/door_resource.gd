class_name DoorResource extends Resource


var maze: MazeResource:
	set = set_maze

var type: String
var rooms: Array

var length = 0
var font_size = 9
var ring = {}
var intersections = []


func set_maze(maze_: MazeResource) -> DoorResource:
	maze = maze_
	maze.doors.append(self)
	connect_rooms()
	return self

func connect_rooms() -> void:
	rooms.front().doors[self] = rooms.back()
	rooms.back().doors[self] = rooms.front()
	
	ring.begin = min(rooms.back().ring, rooms.front().ring)
	ring.end = max(rooms.back().ring, rooms.front().ring)
	
func collapse() -> void:
	rooms.front().doors.erase(self)
	rooms.back().doors.erase(self)
	maze.doors.erase(self)
	
func get_another_room(room_: RoomResource) -> RoomResource:
	var rooms_ = []
	rooms_.append_array(rooms)
	rooms_.erase(room_)
	return rooms_.front()
	
func roll_length() -> void:
	var sector = 0.0
	
	for room in rooms:
		sector += room.sector
	
	sector /= rooms.size()
	Global.rng.randomize()
	length = Global.rng.randi_range(Global.dict.door.length.sector[sector].min, Global.dict.door.length.sector[sector].max)
	
func get_points() -> Array:
	return [rooms[0].position, rooms[1].position]
