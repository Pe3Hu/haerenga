extends Camera2D


var move_speed = 0.5 
var zoom_speed = 0.5 

var focus = null
var maze = null


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	#position = -maze.custom_minimum_size * 0.5
	#zoom = Vector2.ONE * 0.5


func onfocus() -> void:
	if focus != null:
		position = maze.polygons.position + focus.position
		print(focus.index)
		#position = -focus.position
		#print(position)
		pass


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
