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
	
	arr.rarity = ["ordinary" , "unusual", "rare", "epic", "legendary", "mythical"]
	arr.phase = ["draw_hand", "get_pathways", "choose_pathway", "halt"]
	arr.token = ["motion", "acceleration", "salvo", "extraction", "scan", "recharge"]
	arr.resource = ["mineral", "knowledge", "intelligence", "fuel"]
	arr.output = []
	arr.output.append_array(arr.token)
	arr.output.append_array(arr.resource)


func init_num() -> void:
	num.index = {}
	num.index.room = 0
	num.index.door = 0
	num.index.card = 0
	
	num.ring = {}
	num.ring.r = 50
	num.ring.segment = 18#9
	
	num.room = {}
	num.room.r = 8
	
	num.outpost = {}
	num.outpost.r = num.room.r * 2
	
	num.obstacle = {}
	num.obstacle.r = num.room.r * 1.25
	
	num.content = {}
	num.content.r = num.room.r * 0.75
	
	num.areola = {}
	num.areola.r = num.room.r * 2
	
	num.sectors = {}
	num.sectors.primary = 4
	num.sectors.final = 3
	
	num.relevance = {}
	num.relevance.resource = {}
	num.relevance.resource.fuel = 1
	num.relevance.resource.mineral = 2
	num.relevance.resource.knowledge = 3
	num.relevance.resource.energy = 4
	num.relevance.resource.damage = 5
	num.relevance.resource.intelligence = 6
	
	num.relevance.token = {}
	num.relevance.token.recharge = 1
	num.relevance.token.boost = -2
	num.relevance.token.overload = -4
	num.relevance.token.breakage = -8


func init_dict() -> void:
	init_neighbor()
	init_also()
	init_door()
	init_content()
	init_obstacle()
	init_hazard()
	init_loot()
	init_card()


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
	
	var path = "res://asset/json/haerenga_door_length.json"
	var array = load_data(path)
	
	for length in array:
		dict.door.length.sector[float(length.sector)] = {}
		
		for key in length:
			if key != "sector":
				dict.door.length.sector[float(length.sector)][key] = float(length[key])


func init_content() -> void:
	dict.room = {}
	dict.room.content = {}
	
	var path = "res://asset/json/haerenga_content.json"
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
	
	var path = "res://asset/json/haerenga_obstacle.json"
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
	var path = "res://asset/json/haerenga_hazard.json"
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


func init_loot() -> void:
	dict.loot = {}
	dict.loot.chance = {}
	dict.loot.chance.level = {}
	dict.loot.chance.level.rarity = {}
	var path = "res://asset/json/haerenga_loot.json"
	var array = load_data(path)
	
	for loot in array:
		var level = int(loot.level)
		dict.loot.chance.level.rarity[level] = {}
		
		for rarity in arr.rarity:
			if loot[rarity] > 0:
				dict.loot.chance.level.rarity[level][rarity] = loot[rarity]
	
	dict.loot.limit = {}
	dict.loot.limit.rarity = {}
	dict.loot.limit.rarity["ordinary"] = {}
	dict.loot.limit.rarity["ordinary"].min = 15
	dict.loot.limit.rarity["ordinary"].max = 18
	
	for _i in arr.rarity.size():
		if _i > 0:
			var rarity = {}
			rarity.current = arr.rarity[_i]
			rarity.previous = arr.rarity[_i - 1]
			var l = dict.loot.limit.rarity[rarity.previous].max - dict.loot.limit.rarity[rarity.previous].min + 1 
			dict.loot.limit.rarity[rarity.current] = {}
			dict.loot.limit.rarity[rarity.current].min = dict.loot.limit.rarity[rarity.previous].max + 1
			dict.loot.limit.rarity[rarity.current].max = dict.loot.limit.rarity[rarity.current].min + l
	
	dict.loot.limit.rarity["legendary"].max += 2


func init_card() -> void:
	dict.card = {}
	dict.card.index = {}
	dict.card.rarity = {}
	dict.card.starte_kit = {}
	dict.card.starte_kit[4] = 1
	dict.card.starte_kit[7] = 1
#	dict.card.starte_kit[61] = 4
#	dict.card.starte_kit[113] = 6
#	dict.card.starte_kit[116] = 1
#	dict.card.starte_kit[179] = 1
	dict.card.starte_kit[121] = 6
	dict.card.starte_kit[64] = 4
	dict.card.starte_kit[206] = 1
	dict.card.starte_kit[124] = 1
	dict.market = {}
	dict.market.card = {}
	var pairs = []
	var childs = {}
	var weights = {}
	var serif = Time.get_unix_time_from_system()
	
	for token in arr.token:
		var resource = dict.conversion.token.resource[token]
		weights[token] = dict.conversion.token.sign[token] * num.relevance.resource[resource]
	
	weights["motion"] = 2
	
	
	for first in arr.token:
		childs[first] = []
		
		for second in arr.token:
			var pair = [first, second]
			
			if arr.token.find(first) > arr.token.find(second):
				pair = [second, first]
			
			if !pairs.has(pair) and first != second:
				pairs.append(pair)
				childs[first].append(second)
	
	#dict.loot.limit.rarity["legendary"].max
	token_parameterizations(weights, childs, dict.loot.limit.rarity["mythical"].max)
	dict.market = {}
	
	#print("____", dict.market.card[30].keys().size())
	
	#print(Time.get_unix_time_from_system() - serif)


func token_parameterizations(weights_: Dictionary, childs_: Dictionary,  limit_: int) -> void:
	var charges = [1, 2,3,4,5]
	var limit = ceil(limit_ / 2)
	
	for conversion in range(2, limit):
		for parent in weights_:
			for child in childs_[parent]:
				for charge in charges:
					var subtypes = {}
					subtypes = get_subtypes_based_on_value(weights_, subtypes, parent, conversion, charge)
					
					while subtypes.has(parent):
						subtypes = replace_parent_with_child(weights_, subtypes, parent, child, conversion, charge)


func replace_parent_with_child(weights_: Dictionary, subtypes_: Dictionary, parent_: String, child_: String, conversion_: int, charge_: int) -> Dictionary:
	subtypes_[parent_] -= 1
	
	if !subtypes_.has(child_):
		subtypes_[child_] = 0
	subtypes_[child_] += 1
	
	if subtypes_[parent_] == 0:
		subtypes_.erase(parent_)
	
	return get_subtypes_based_on_value(weights_, subtypes_, child_, conversion_, charge_)


func get_subtypes_based_on_value(weights_: Dictionary, subtypes_: Dictionary, child_: String, conversion_: int, charge_: int) -> Dictionary:
	var subtypes = {}
	var conversion = 0
	
	for subtype in subtypes_:
		subtypes[subtype] = subtypes_[subtype]
		conversion += weights_[subtype] * subtypes[subtype]
	
		add_card(weights_, subtypes, charge_)
	
	while conversion < conversion_:
		if !subtypes.has(child_):
			subtypes[child_] = 0
		
		subtypes[child_] += 1
		conversion += weights_[child_]
		
		add_card(weights_, subtypes, charge_)
	
	return subtypes


func add_card(weights_: Dictionary, subtypes_: Dictionary, charge_: int) -> void:
	var conversion = 0
	var keys = subtypes_.keys()
	
	keys.sort_custom(func(a, b): return arr.token.find(a) < arr.token.find(b))
	var subtypes = {}
	
	for key in keys:
		subtypes[key] = subtypes_[key]
		conversion += subtypes[key] * weights_[key] * charge_
	
	subtypes.charge = charge_
	
	if conversion >= dict.loot.limit.rarity["ordinary"].min and conversion <= dict.loot.limit.rarity["mythical"].max:
		if !dict.market.card.has(conversion):
			dict.market.card[conversion] = {}
		
		if !dict.market.card[conversion].has(subtypes):
			if charge_ > 1 or conversion >= dict.loot.limit.rarity["epic"].min:
				#print([num.index.card, conversion, subtypes])
				dict.market.card[conversion][subtypes] = num.index.card#{}
				#dict.market.card[conversion][subtypes].index = num.index.card
				#dict.market.card[conversion][subtypes].charge = charge_
				#print([conversion, subtypes])
				dict.card.index[num.index.card] = {}
				dict.card.index[num.index.card].token = {}
				dict.card.index[num.index.card].limit = {}
				dict.card.index[num.index.card].limit.charge = subtypes.charge
				dict.card.index[num.index.card].limit.toughness = 1
				dict.card.index[num.index.card].rarity = get_rarity(conversion)
				dict.card.index[num.index.card].price = conversion
				
				if !dict.card.rarity.has(dict.card.index[num.index.card].rarity):
					dict.card.rarity[dict.card.index[num.index.card].rarity] = []
				
				dict.card.rarity[dict.card.index[num.index.card].rarity].append(num.index.card)
				
				for subtype in arr.token:
					if subtypes.has(subtype):
						dict.card.index[num.index.card].token[subtype] = subtypes[subtype]
				
				#print(num.index.card, subtypes)
				num.index.card += 1


func get_rarity(conversion_: int) -> Variant:
	for rarity in dict.loot.limit.rarity:
		if dict.loot.limit.rarity[rarity].min <= conversion_ and dict.loot.limit.rarity[rarity].max >= conversion_:
			return rarity
	
	return null


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_scene() -> void:
	scene.sketch = load("res://scene/0/sketch.tscn")
	scene.icon = load("res://scene/0/icon.tscn")
	scene.minimap = load("res://scene/0/minimap.tscn")
	
	scene.door = load("res://scene/1/door.tscn")
	scene.room = load("res://scene/1/room.tscn")
	
	scene.outpost = load("res://scene/2/outpost.tscn")
	scene.lair = load("res://scene/2/lair.tscn")
	scene.obstacle = load("res://scene/2/obstacle.tscn")
	scene.content = load("res://scene/2/content.tscn")
	
	scene.nexus = load("res://scene/3/nexus.tscn")
	scene.core = load("res://scene/3/core.tscn")
	scene.van = load("res://scene/3/van.tscn")
	
	scene.crossroad = load("res://scene/4/crossroad.tscn")
	scene.pathway = load("res://scene/4/pathway.tscn")
	scene.tree = load("res://scene/4/tree.tscn")
	
	scene.card = load("res://scene/5/card.tscn")
	scene.token = load("res://scene/5/token.tscn")
	scene.resource = load("res://scene/5/resource.tscn")
	scene.crown = load("res://scene/5/crown.tscn")
	
	pass


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


func get_random_obstacle_and_content(sector_: int) -> Dictionary:
	var result = {}
	var weights = {}
	weights.content = {}
	
	for content in dict.room.content:
		weights.content[content] = dict.room.content[content].sector[sector_].rarity
	
	result.content = get_random_key(weights.content)
	weights.obstacle = {}
	
	for obstacle in dict.room.obstacle:
		weights.obstacle[obstacle] = dict.room.obstacle[obstacle].sector[sector_].rarity
	
	if result.content == "empty":
		weights.obstacle["empty"] *= 3
	
	result.obstacle = get_random_key(weights.obstacle)
	return result


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
