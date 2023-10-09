extends Camera2D


@onready var areola = $Areola


var move_speed = 0.5 
var zoom_speed = 0.5 

var focus = null
var maze = null


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	#position = -maze.custom_minimum_size * 0.5
	#zoom = Vector2.ONE * 0.5
	init_vertexs()


func init_vertexs() -> void:
	var n = 4
	var vertexs = []
	var angle = PI * 2 / n
	
	for _i in n:
		var vertex = Vector2.from_angle(angle * _i) * Global.num.areola.r
		vertexs.append(vertex)
	
	areola.set_polygon(vertexs)


func onfocus() -> void:
	if focus != null:
		position = maze.polygons.position + focus.position
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
