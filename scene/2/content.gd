extends Polygon2D


var maze = null
var room = null
var type = null
var value = null
var active = true


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	room = input_.room
	type = input_.type
	position = room.position
	set_default_color()
	
	init_vertexs()
	set_value()


func init_vertexs() -> void:
	var n = 4
	var vertexs = []
	var angle = PI * 2 / n
	
	for _i in n:
		var vertex = Vector2.from_angle(angle * _i) * Global.num.content.r
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func set_value() -> void:
	value = Global.dict.room.content[type].sector[room.sector].value


func update_color_based_on_core_intelligence(core_) -> void:
	if core_ != null:
		if core_.intelligence.room.has(room):
			set_default_color()
			return
	
	color = Global.color.content["unknown"]


func set_default_color() -> void:
	color = Global.color.content[type]


func deactivate() -> void:
	active = false
	value = 0
	type = "empty"
	set_default_color()
