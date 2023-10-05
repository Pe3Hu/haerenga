extends MarginContainer

@onready var gameboard = $VBox/Gameboard
@onready var crossroad = $VBox/Crossroad

var nexus = null
var maze = null
var outpost = null
var room = null


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	maze = nexus.sketch.maze
	
	var input = {}
	input.core = self
	crossroad.set_attributes(input)
	spaw_on_outpost()
	gameboard.set_attributes(input)
	set_local_ambition()


func spaw_on_outpost() -> void:
	outpost = maze.outposts.get_children().pick_random()
	room = outpost.room
	maze.focus_on_room(room)
	crossroad.update_room()


func set_local_ambition() -> void:
	var solutions = get_local_solutions()
	var rewards = get_local_rewards(solutions)
	choice_of_loacl_options(rewards)


func get_local_solutions() -> Dictionary:
	var destinations = {}
	
	for pathway in crossroad.pathways.get_children():
		var destination = pathway.rooms.destination
		destinations[destination] = []
		var solutions = []
		
		if destination.obstacle.subtype != "empty" and destination.obstacle.active:
			solutions = destination.obstacle.get_solutions()
		else:
			solutions.append({})
		
		for solution in solutions:
			if !solution.has("motion"):
				solution["motion"] = 0
			
			solution["motion"] += pathway.doorlength.get_number()
			
			#print(solution)
			
			if solution_availability_check(solution):
				destinations[destination].append(solution)
	
	return destinations


func get_local_rewards(destinations_: Dictionary) -> Dictionary:
	var rewards = {}
	
	for destination in destinations_:
		if destination.content.active:
			var description = Global.dict.room.content[destination.content.type]
			
			if description.output != "no":
				rewards[destination] = {}
				rewards[destination].reward = {}
				rewards[destination].reward.resource = description.output
				rewards[destination].reward.value = description.sector[destination.sector].value
				rewards[destination].solutions = []
				
				for solution in destinations_[destination]:
					var fee = 1
				
					if solution.has(description.input):
						fee += solution[description.input]
					
					if description.input == "free" or token_availability_check(description.input, fee):
						if description.input != "free":
							if !solution.has(description.input):
								solution[description.input] = 0
						
							solution[description.input] += 1
						
						
						rewards[destination].solutions.append(solution)
	
	return rewards


func choice_of_loacl_options(destinations_: Dictionary) -> void:
	var datas = []
	#print(destinations_)
	for destination in destinations_:
		for solution in destinations_[destination].solutions:
			var data = {}
			data.destination = destination
			data.solution = solution
			data.reward = destinations_[destination].reward
			data.weight = {}
			data.weight.solution = 0
			var unspent = {}
			
			for token in Global.arr.token:
				if Global.dict.conversion.token.resource.has(token):
					var resource = Global.dict.conversion.token.resource[token]
					unspent[token] = gameboard.get_token_stack_value(token)
					
					if solution.has(token):
						unspent[token] -= solution[token]
					
					if Global.num.relevance.resource.has(resource):
						data.weight.solution += unspent[token] * Global.num.relevance.resource[resource]
			
			
			#for resource in data.reward:
			data.weight.reward = data.reward.value * Global.num.relevance.resource[data.reward.resource]
			data.weight.total = data.weight.solution + data.weight.reward
			datas.append(data)
	
	
	datas.sort_custom(func(a, b): return a.weight.total > b.weight.total)
	for data in datas:
		print([data.destination.obstacle.subtype, data])


func solution_availability_check(solution_: Dictionary) -> bool:
	for subtype in solution_:
		if !token_availability_check(subtype, solution_[subtype]):
			return false
	
	return true


func token_availability_check(subtype_: String, value_: int) -> bool:
	if subtype_ == "free":
		return true
	
	return gameboard.get_token_stack_value(subtype_) >= value_


func expedition_check_for_continuation(destination_: Dictionary) -> bool:
	
	return false
