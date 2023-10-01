extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var flag = {}
var node = {}
var scene = {}


func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_color()
	init_dict()
	init_node()
	init_scene()


func init_arr() -> void:
	arr.sequence = {}
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	arr.edge = [1, 2, 3, 4, 5, 6]
	
	arr.aspect = ["power", "autonomy", "velocity"]
	arr.synergy = ["totem", "origin", "kind"]
	arr.purpose = ["dominance", "obedience"]


func init_num() -> void:
	num.index = {}
	num.index.room = 0
	num.index.door = 0
	
	num.ring = {}
	num.ring.r = 25
	num.ring.segment = 11#9
	
	num.room = {}
	num.room.r = 7


func init_dict() -> void:
	init_neighbor()
	
	dict.ring = {}
	dict.ring.weight = {}
	dict.ring.weight["single"] = 7
	dict.ring.weight["trapeze"] = 5
	dict.ring.weight["equal"] = 9
	dict.ring.weight["double"] = 3
	#dict.ring.weight["triple"] = 1
	
	dict.slot = {}
	dict.slot.aspect = {}
	dict.slot.aspect["Head"] = "power"
	dict.slot.aspect["Torso"] = "autonomy"
	dict.slot.aspect["Limb"] = "velocity"
	
	dict.aspect = {}
	dict.aspect.slot = {}
	dict.aspect.slot["power"] = "Head"
	dict.aspect.slot["autonomy"] = "Torso"
	dict.aspect.slot["velocity"] = "Limb"


func init_neighbor() -> void:
	dict.neighbor = {}
	dict.neighbor.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.neighbor.linear2 = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	dict.neighbor.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	dict.neighbor.zero = [
		Vector2( 0, 0),
		Vector2( 1, 0),
		Vector2( 1, 1),
		Vector2( 0, 1)
	]
	dict.neighbor.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_scene() -> void:
	scene.sketch = load("res://scene/0/sketch.tscn")
	
	scene.door = load("res://scene/1/door.tscn")
	scene.room = load("res://scene/1/room.tscn")
	pass


func init_vec():
	vec.size = {}
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	color.indicator = {}


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var parse_err = json_object.parse(text)
	return json_object.get_data()


func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null


func check_lines_intersection(lines_: Array) -> bool:
	var intersection = get_lines_intersection(lines_)
	if intersection != null:
		return check_point_inside_rect(intersection, lines_[0]) and check_point_inside_rect(intersection, lines_[1])
	else:
		return true


func get_lines_intersection(lines_: Array) -> Variant:
	var a = lines_[0][0]
	var b = lines_[0][1]
	var c = lines_[1][0]
	var d = lines_[1][1]
	
	var dir_a = b - a
	var dir_c = d - c
	var vertex = Geometry2D.line_intersects_line(a, dir_a, c, dir_c)
	return vertex


func check_point_inside_rect(point_: Vector2, rect_: Array) -> bool:
	var min = Vector2()
	min.x = min(rect_.front().x, rect_.back().x)
	min.y = min(rect_.front().y, rect_.back().y)
	var max = Vector2()
	max.x = max(rect_.front().x, rect_.back().x)
	max.y = max(rect_.front().y, rect_.back().y)
	return point_.x >= min.x and point_.x <= max.x and point_.y >= min.y and point_.y <= max.y
