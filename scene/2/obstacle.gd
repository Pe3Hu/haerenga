extends Polygon2D


var maze = null
var room = null
var type = null
var subtype = null
var requirement = 0


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	room = input_.room
	#type = input_.type
	subtype = input_.subtype
	position = room.position
	color = Global.color.obstacle[subtype]
	
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
	var base = Global.dict.room.obstacle[subtype].sector[room.sector].requirement
	
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
		solutions.append(kinds)
		
		while kinds.has("primary"):
			kinds = replace_primary_with_alternative(kinds)
			solutions.append(kinds)
		
		
		kinds = ["shortcut"]
		kinds = make_solution_based_on_kinds(kinds, "primary")
		solutions.append(kinds)
		
		while kinds.has("primary"):
			kinds = replace_primary_with_alternative(kinds)
			solutions.append(kinds)
		
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
	
	return []


func replace_primary_with_alternative(kinds_: Array) -> Array:
	kinds_.erase("primary")
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
