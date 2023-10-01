extends Polygon2D


var maze = null
var room = null
var type = null


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	room = input_.room
	type = input_.type
	position = room.position
	color = Global.color.obstacle[type]
	
	init_vertexs()


func init_vertexs() -> void:
	var n = 4
	var vertexs = []
	var angle = PI * 2 / n
	
	for _i in n:
		var vertex = Vector2.from_angle(angle * _i) * Global.num.obstacle.r
		vertexs.append(vertex)
	
	set_polygon(vertexs)
