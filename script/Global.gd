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


func init_arr() -> void:
	arr.part = ["tail", "torso", "head"]
	
func init_num() -> void:
	num.relevance = {}
	
func init_dict() -> void:
	init_neighbor()
	#init_ring()
	init_door()
	init_content()
	init_obstacle()
	init_hazard()
	init_compartment()
	init_module()
	
func init_ring() -> void:
	dict.ring = {}
	dict.ring.weight = {}
	dict.ring.weight["single"] = 7
	dict.ring.weight["trapeze"] = 5
	dict.ring.weight["equal"] = 9
	dict.ring.weight["double"] = 3
	#dict.ring.weight["triple"] = 1
	
	
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
	
func init_door() -> void:
	dict.door = {}
	dict.door.length = {}
	dict.door.length.sector = {}
	
	var path = "res://entities/door/door_length.json"
	var array = load_data(path)
	
	for length in array:
		dict.door.length.sector[float(length.sector)] = {}
		
		for key in length:
			if key != "sector":
				dict.door.length.sector[float(length.sector)][key] = float(length[key])
	
func init_content() -> void:
	dict.room = {}
	dict.room.content = {}
	
	var path = "res://entities/room/jsons/content.json"
	var array = load_data(path)
	
	for content in array:
		var data = {}
		data.sector = {}
		
		for key in content:
			var words = key.split(" ")
			
			if words.has("sector"):
				var sector = int(words[2])
				
				if !data.sector.has(sector):
					data.sector[sector] = {}
				
				data.sector[sector][words[0]] = content[key]
			else:
				data[key] = content[key]
		
		dict.room.content[content.type] = data
	
func init_obstacle() -> void:
	dict.room.obstacle = {}
	
	var path = "res://entities/room/jsons/obstacle.json"
	var array = load_data(path)
	
	for obstacle in array:
		var data = {}
		data.sector = {}
		data.token = {}
		data.impact = {}
		
		for key in obstacle:
			var words = key.split(" ")
			
			if words.size() > 1:
				if words.has("sector"):
					var sector = int(words[2])
					
					if !data.sector.has(sector):
						data.sector[sector] = {}
					
					data.sector[sector][words[0]] = obstacle[key]
			
				if words.has("token"):
					data.token[words[0]] = obstacle[key]
				
				if words.has("impact"):
					data.impact[words[0]] = obstacle[key]
			else:
				data[key] = obstacle[key]
		
		dict.room.obstacle[obstacle.subtype] = data
	
func init_hazard() -> void:
	dict.hazard = {}
	var path = "res://entities/room/jsons/hazard.json"
	var array = load_data(path)
	
	for hazard in array:
		var data = {}
		data.sector = {}
		var rank = int(hazard.rank)
		
		for key in hazard:
			var words = key.split(" ")
			
			if words.size() > 1:
				if words.has("sector"):
					var sector = int(words[2])
					
					if !data.sector.has(sector):
						data.sector[sector] = {}
					
					data.sector[sector][words[0]] = hazard[key]
				else:
					data[key] = hazard[key]
		
		dict.hazard[rank] = data
	
func init_compartment() -> void:
	dict.compartment = {}
	dict.compartment.index = {}
	dict.compartment.part = {}
	dict.compartment.size = {}
	var exceptions = ["index"]
	
	var path = "res://entities/compartment/compartment.json"
	var array = load_data(path)
	
	for compartment in array:
		compartment.index = int(compartment.index)
		compartment.size = int(compartment.size)
		var data = {}
		data.modules = []
		
		for key in compartment:
			if !exceptions.has(key):
				if key.contains("module"):
					data.modules.append(int(compartment[key]))
				else:
					data[key] = compartment[key]
		
		dict.compartment.index[compartment.index] = data
		
		if compartment.part != "all":
			if !dict.compartment.part.has(compartment.part):
				dict.compartment.part[compartment.part] = []
			
			dict.compartment.part[compartment.part].append(compartment.index)
		else:
			for part in dict.compartment.part:
				dict.compartment.part[part].append(compartment.index)
		
		if !dict.compartment.size.has(compartment.size):
			dict.compartment.size[compartment.size] = []
		
		dict.compartment.size[compartment.size].append(compartment.index)
	
	#dict.compartment.part["any"] = []
	#dict.compartment.size["any"] = []
	
	#for part in dict.compartment.part:
		#if part != "any":
			#dict.compartment.part["any"].append_array(dict.compartment.part[part])
	
	#for size in dict.compartment.size:
		#if size != "any":
			#dict.compartment.size["any"].append_array(dict.compartment.size[size])
	
func init_module() -> void:
	dict.module = {}
	dict.module.index = {}
	dict.module.part = {}
	dict.module.order = {}
	var exceptions = ["index"]
	
	var path = "res://entities/module/module.json"
	var array = load_data(path)
	
	for module in array:
		module.index = int(module.index)
		module.order = int(module.order)
		var data = {}
		data.sockets = {}
		
		for key in module:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if words.size() > 1:
					if !data.sockets.has(words[0]):
						data.sockets[words[0]] = {}
					
					data.sockets[words[0]][words[1]] = module[key]
				else:
					data[key] = module[key]
		
		dict.module.index[module.index] = data
		
		if !dict.module.part.has(module.part):
			dict.module.part[module.part] = {}
		
		#dict.module.part[module.part].append(module.index)
		
		if !dict.module.part[module.part].has(module.order):
			dict.module.part[module.part][module.order] = []
		
		dict.module.part[module.part][module.order].append(module.index)
	
func init_vec():
	vec.size = {}
	vec.size.letter = Vector2(20, 20)
	vec.size.icon = Vector2(48, 48)
	vec.size.number = Vector2(5, 32)
	
	
	for key in vec.size:
		if key != "letter":
			vec.size[key] = Vector2(32, 32)
	
	vec.size.number = Vector2(16, 32)
	
	init_window_size()
	
func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)
	
func init_color():
	var max_h = 360.0
	
	color.obstacle = {}
	color.obstacle["unknown"] = Color.from_hsv(6 / max_h, 0.61, 0.83)
	color.obstacle["empty"] = Color.from_hsv(330 / max_h, 0.0, 0.9)
	
	color.obstacle["labyrinth"] = Color.from_hsv(150 / max_h, 0.85, 0.9)
	color.obstacle["landslide"] = Color.from_hsv(90 / max_h, 0.85, 0.9)
	color.obstacle["anomaly"] = Color.from_hsv(210 / max_h, 0.85, 0.9)
	color.obstacle["conundrum"] = Color.from_hsv(270 / max_h, 0.85, 0.9)
	color.obstacle["raid"] = Color.from_hsv(330 / max_h, 0.85, 0.9)
	color.obstacle["ambush"] = Color.from_hsv(30 / max_h, 0.85, 0.9)
	
	color.content = {}
	color.content["unknown"] = Color.from_hsv(6 / max_h, 0.61, 0.83)
	color.content["empty"] = Color.from_hsv(47 / max_h, 1.0, 0.96)
	color.content["mine"] = Color.from_hsv(29 / max_h, 0.44, 0.94)
	color.content["terminal"] = Color.from_hsv(218 / max_h, 0.68, 0.48)
	color.content["ruin"] = Color.from_hsv(20 / max_h, 0.8, 1.0)
	color.content["watchtower"] = Color.from_hsv(168 / max_h, 0.74, 0.83)
	color.content["powerhouse"] = Color.from_hsv(210 / max_h, 0.14, 0.97)
	color.content["warehouse"] = Color.from_hsv(207 / max_h, 0.15, 0.23)
	color.content["library"] = Color.from_hsv(10 / max_h, 0.1, 0.47)
	
	color.rarity = {}
	#color.rarity["ordinary"] = Color.from_hsv(210 / max_h, 0.5, 0.2)
	color.rarity["ordinary"] = Color.from_hsv(210 / max_h, 0.2, 0.6)
	#color.rarity["unusual"] = Color.from_hsv(140 / max_h, 0.8, 0.3)
	color.rarity["unusual"] = Color.from_hsv(140 / max_h, 0.9, 0.6)
	#color.rarity["rare"] = Color.from_hsv(210 / max_h, 0.9, 0.3)
	color.rarity["rare"] = Color.from_hsv(210 / max_h, 0.9, 0.6)
	#color.rarity["epic"] = Color.from_hsv(300 / max_h, 0.7, 0.4)
	color.rarity["epic"] = Color.from_hsv(300 / max_h, 0.9, 0.6)
	#color.rarity["legendary"] = Color.from_hsv(50 / max_h, 0.8, 0.5)
	color.rarity["legendary"] = Color.from_hsv(60 / max_h, 0.9, 0.8)
	#color.rarity["mythical"] = Color.from_hsv(0 / max_h, 0.9, 0.6)
	color.rarity["mythical"] = Color.from_hsv(0 / max_h, 0.8, 0.9)
	
	color.van = {}
	color.van["active"] = Color.from_hsv(140 / max_h, 0.4, 0.6)
	color.van["inactive"] = Color.from_hsv(0 / max_h, 0.3, 0.6)
	
func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)
	
func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
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
		return false

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
	var value = {}
	value.min = Vector2()
	value.max = Vector2()
	value.min.x = min(rect_.front().x, rect_.back().x)
	value.min.y = min(rect_.front().y, rect_.back().y)
	value.max.x = max(rect_.front().x, rect_.back().x)
	value.max.y = max(rect_.front().y, rect_.back().y)
	return point_.x >= value.min.x and point_.x <= value.max.x and point_.y >= value.min.y and point_.y <= value.max.y

func get_random_hazard(sector_: int) -> int:
	var weights = {}
	
	for hazard in dict.hazard:
		weights[hazard] = dict.hazard[hazard].sector[sector_].rarity
	
	var result = get_random_key(weights)
	return result

func get_token_kind_based_on_obstacle(obstacle_: String, token_: String) -> Variant:
	for kind in Global.dict.room.obstacle[obstacle_].token:
		if Global.dict.room.obstacle[obstacle_].token[kind] == token_:
			return kind
	
	return null
