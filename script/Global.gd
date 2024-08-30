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
	arr.sequence = {}


func init_num() -> void:
	num.relevance = {}
	

func init_dict() -> void:
	init_neighbor()
	init_also()
	init_door()
	init_content()
	init_obstacle()
	init_hazard()


func init_also() -> void:
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
	
	dict.thousand = {}
	dict.thousand[""] = "k"
	dict.thousand["k"] = "m"
	dict.thousand["m"] = "b"
	
	dict.conversion = {}
	dict.conversion.token = {}
	dict.conversion.token.resource = {}
	dict.conversion.token.resource["motion"] = "fuel"
	dict.conversion.token.resource["acceleration"] = "knowledge"
	dict.conversion.token.resource["salvo"] = "damage"
	dict.conversion.token.resource["extraction"] = "mineral"
	dict.conversion.token.resource["scan"] = "intelligence"
	dict.conversion.token.resource["recharge"] = "energy"
	dict.conversion.token.resource["boost"] = "fuel"
	dict.conversion.token.resource["overload"] = "energy"
	dict.conversion.token.resource["breakage"] = "spares"
	
	dict.conversion.token.sign = {}
	dict.conversion.token.sign["motion"] = -1
	dict.conversion.token.sign["acceleration"] = 1
	dict.conversion.token.sign["salvo"] = 1
	dict.conversion.token.sign["extraction"] = 3
	dict.conversion.token.sign["scan"] = 1
	dict.conversion.token.sign["recharge"] = 1
	dict.conversion.token.sign["boost"] = -2
	dict.conversion.token.sign["overload"] = -1
	dict.conversion.token.sign["breakage"] = -1


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
	color.obstacle["empty"] = Color.from_hsv(47 / max_h, 1.0, 0.96)
	color.obstacle["conundrum"] = Color.from_hsv(277 / max_h, 0.58, 0.91)
	color.obstacle["raid"] = Color.from_hsv(5 / max_h, 0.92, 0.98)
	color.obstacle["labyrinth"] = Color.from_hsv(152 / max_h, 0.87, 0.85)
	color.obstacle["landslide"] = Color.from_hsv(181 / max_h, 1.0, 1.0)
	color.obstacle["ambush"] = Color.from_hsv(207 / max_h, 0.47, 0.37)
	color.obstacle["anomaly"] = Color.from_hsv(224 / max_h, 0.71, 1.0)
	
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
