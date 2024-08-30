class_name MazeCamera extends Camera2D


@export var maze: Maze
@export var areola: Polygon2D

var resource: CameraResource:
	set(resource_):
		resource = resource_


func set_room(room_: RoomResource) -> void:
	resource.room = room_
	position = maze.node2Ds.position + resource.room.position
	
func move_camera(direction_: String) -> void:
	var vector = Vector2()
	
	match direction_:
		"up":
			vector += Vector2(0, -1)
		"right":
			vector += Vector2(1, 0)
		"down":
			vector += Vector2(0, 1)
		"left":
			vector += Vector2(-1, 0)
	
	position += vector * 10
	
func zoom_it(direction_: String) -> void:
	match direction_:
		"-":
			zoom += Vector2(-0.1, -0.1)
		"+":
			zoom += Vector2(0.1, 0.1)
