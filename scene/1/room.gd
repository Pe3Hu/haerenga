extends Polygon2D


var maze = null
var outpost = null
var obstacle = null
var content = null
var backdoor = null
var ring = null
var order = null
var index = null
var icon = null
var sector = null
var doors = {}


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	order = input_.order
	ring = input_.ring
	backdoor = input_.backdoor
	position = input_.position
	index = Global.num.index.room
	Global.num.index.room += 1
	
	var input = {}
	input.type = "number"
	input.subtype = index
	icon = Global.scene.icon.instantiate()
	maze.iroom.add_child(icon)
	icon.set_attributes(input)
	icon.position = position
	
	#icon.position.x -= maze.get("theme_override_constants/margin_left")
	#icon.position.y -= maze.get("theme_override_constants/margin_top")
	
	maze.rings.room[ring].append(self)
	update_color_based_on_ring()
	init_vertexs()


func init_vertexs() -> void:
	var n = 4
	var vertexs = []
	var angle = PI * 2 / n
	
	for _i in n:
		var vertex = Vector2.from_angle(angle * _i) * Global.num.room.r
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


func set_sector(sector_: int) -> void:
	sector = sector_
	update_color_based_on_sector()


func update_color_based_on_sector() -> void:
	var s = 0.75
	var v = 1
	var h = float(sector) / Global.num.sectors.final
	var color_ = Color.from_hsv(h, s, v)
	set_color(color_)


func add_outpost() -> void:
	var input = {}
	input.maze = maze
	input.room = self
	
	outpost = Global.scene.outpost.instantiate()
	maze.outposts.add_child(outpost)
	outpost.set_attributes(input)
	add_obstacle("empty")
	add_content("empty")


func add_obstacle(obstacle_: String) -> void:
	var input = {}
	input.maze = maze
	input.room = self
	input.subtype = obstacle_
	
	obstacle = Global.scene.obstacle.instantiate()
	maze.obstacles.add_child(obstacle)
	obstacle.set_attributes(input)


func add_content(content_: String) -> void:
	var input = {}
	input.maze = maze
	input.room = self
	input.type = content_
	
	content = Global.scene.content.instantiate()
	maze.contents.add_child(content)
	content.set_attributes(input)


func get_door_based_on_neighbor(neighbor_: Polygon2D) -> Variant:
	for door in doors:
		if doors[door] == neighbor_:
			return door
	
	return null
