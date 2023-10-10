extends Polygon2D


var maze = null
var room = null
var type = null
var subtype = null
var requirement = 0
var penalty = {}
var active = true


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	room = input_.room
	#type = input_.type
	subtype = input_.subtype
	position = room.position
	set_default_color()
	
	init_vertexs()
	roll_requirement()


func init_vertexs() -> void:
	var n = 4
	var vertexs = []
	var angle = PI * 2 / n
	
	for _i in n:
		var vertex = Vector2.from_angle(angle * _i) * Global.num.obstacle.r
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func roll_requirement() -> void:
	var description = Global.dict.room.obstacle[subtype]
	var base = description.sector[room.sector].requirement
	penalty[description.token.penalty] = description.sector[room.sector].penalty
	
	if base > 0:
		var limit = floor(base * 0.25)
		var complexities = {}

		for _i in limit:
			complexities[base + _i] = int(limit - _i)
		
		requirement = Global.get_random_key(complexities)


func get_solutions() -> Array:
	if requirement > 0:
		var solutions = []
		var description = Global.dict.room.obstacle[subtype]
		var kinds = []
		kinds = make_solution_based_on_kinds(kinds, "primary")
		solutions.append(kinds.duplicate())
		
		while kinds.has("primary"):
			kinds = replace_primary_with_alternative(kinds)
			solutions.append(kinds.duplicate())
		
		kinds = ["shortcut"]
		kinds = make_solution_based_on_kinds(kinds, "primary")
		solutions.append(kinds.duplicate())
		
		while kinds.has("primary"):
			kinds = replace_primary_with_alternative(kinds)
			solutions.append(kinds.duplicate())
		
		var result = []
		
		for solution in solutions:
			var tokens = {}
			
			for kind in solution:
				var token = description.token[kind]
				
				if !tokens.has(token):
					tokens[token] = 0
				
				tokens[token] += 1
			
			result.append(tokens)
		
		return result
	
	return [{"motion": 0}]


func replace_primary_with_alternative(kinds_: Array) -> Array:
	kinds_.erase("primary")
	kinds_.append("alternative")
	return make_solution_based_on_kinds(kinds_, "alternative")


func make_solution_based_on_kinds(kinds_: Array, priority_: String) -> Array:
	var solution = []
	var value = 0
	
	for kind in kinds_:
		solution.append(kind)
		value += Global.dict.room.obstacle[subtype].impact[kind]
	
	while value < requirement:
		solution.append(priority_)
		value += Global.dict.room.obstacle[subtype].impact[priority_]
	
	return solution


func update_color_based_on_core_intelligence(core_) -> void:
	if core_ != null:
		if core_.intelligence.room.has(room):
			set_default_color()
			return
	
	color = Global.color.obstacle["unknown"]


func set_default_color() -> void:
	color = Global.color.obstacle[subtype]


func check_solution(pathway_: MarginContainer) -> bool:
	if subtype == "empty":
		return true
	
	if active:
		if requirement > 0:
			var solution = {}
			
			for token in pathway_.inputtokens.get_children():
				var subtype_ = token.title.subtype
				solution[subtype_] = pathway_.get_token_stack_value("input", subtype_)
			
			#solution["motion"] -= pathway_.motionvalue.get_number()
			
			if pathway_.crossroad.origin != null:
				solution["motion"] -= pathway_.crossroad.origin.motionvalue.get_number()
				
				for token in pathway_.crossroad.origin.inputtokens.get_children():
					var subtype_ = token.title.subtype
					solution[subtype_] -= pathway_.get_token_stack_value("input", subtype_)
			
			var value = 0
			for subtype_ in solution:
				var kind = Global.get_token_kind_based_on_obstacle(subtype, subtype_)
				if kind != null:
					value += Global.dict.room.obstacle[subtype].impact[kind] * solution[subtype_]
			
			print([solution, value, requirement])
			return value >= requirement
	
	return true


func deactivate() -> void:
	if subtype != "empty":
		print([room.index, subtype])
		active = false
		requirement = 0
		type = "empty"
		subtype = "empty"
		penalty = {}
		set_default_color()
