extends Polygon2D


var maze = null
var ring = null
var backdoor = null
var order = null
var index = null
var doors = {}


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	order = input_.order
	ring = input_.ring
	backdoor = input_.backdoor
	position = input_.position
	index = Global.num.index.room
	Global.num.index.room += 1
	
	
	maze.rings.room[ring].append(self)
	update_color_based_on_ring()
	init_vertexs()


func init_vertexs() -> void:
	var n = 4
	var vertexs = []
	var angle = PI * 2 / n
	
	for _i in n:
		var vertex = Vector2().from_angle(angle * _i) * Global.num.room.r
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func update_color_based_on_ring() -> void:
	if !backdoor:
		var max_h = 360.0
		var s = 0.75
		var v = 1
		var h = 0
		var odd = ring % 6
		
		match odd:
			0:
				h = 0 / max_h
			1:
				h = 210 / max_h
			2:
				h = 120 / max_h
			3:
				h = 270 / max_h
			4:
				h = 300 / max_h
			5:
				h = 60 / max_h
		
		var color_ = Color.from_hsv(h, s, v)
		set_color(color_)


func paint_white() -> void:
	set_color(Color.WHITE)
