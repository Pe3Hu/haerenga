extends MarginContainer


@onready var tree = $Tree
@onready var pathways = $Pathways

var core = null
var pathway = null
var room = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	pathway = input_.pathway
	
	var input = {}
	input.crossroad = self
	tree.set_attributes(input)


func set_room(room_: Polygon2D) -> void:
	room = room_
	reset_pathways()


func reset_pathways() -> void:
	for pathway in pathways.get_children():
		pathways.remove_child(pathway)
		pathway.queue_free()


func fill_pathways() -> void:
	tree.set_shortest_routes_based_on_dijkstra()
	var destinations = tree.destinations.keys()
	destinations.sort_custom(func(a, b): return  tree.destinations[a].length <  tree.destinations[b].length)
	
	for destination in destinations:
		if room != destination:
			var input = {}
			input.core = core
			input.crossroad = self
			input.length = tree.destinations[destination].length
			input.departure = room
			input.destination = destination
			
			var pathway = Global.scene.pathway.instantiate()
			pathways.add_child(pathway)
			pathway.set_attributes(input)
		#pathway.add_tokens("input", "motion", input.length)


func get_pathway(destination_: Polygon2D) -> Variant:
	for pathway in pathways.get_children():
		if pathway.rooms.destination == destination_:
			return pathway
	
	return null


func set_local_ambition() -> void:
	fill_pathways()
	var solutions = get_local_solutions()
	var rewards = get_local_rewards(solutions)
	prepare_local_options(rewards)


func get_local_solutions() -> Dictionary:
	var destinations = {}
	
	for pathway in pathways.get_children():
		var destination = pathway.rooms.destination
		destinations[destination] = []
		var solutions = []
		
		if core.intelligence.room.has(destination):
			if destination.obstacle.subtype != "empty" and destination.obstacle.active:
				solutions = destination.obstacle.get_solutions()
		
		if solutions.is_empty():
			solutions.append({})#{"motion": 0})
		
		for solution in solutions:
			if !solution.has("motion"):
				solution["motion"] = 0
			
			solution["motion"] += pathway.motionvalue.get_number()
			
			if core.solution_availability_check(solution):
				solution["motion"] -= pathway.motionvalue.get_number()
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
				rewards[destination].reward[description.output] = description.sector[destination.sector].value
				#rewards[destination].reward.resource = description.output
				#rewards[destination].reward.value = description.sector[destination.sector].value
				rewards[destination].solutions = []
				
				for solution in destinations_[destination]:
					var fee = 1
				
					if solution.has(description.input):
						fee += solution[description.input]
					
					if description.input == "free" or core.token_availability_check(description.input, fee):
						if description.input != "free":
							if !solution.has(description.input):
								solution[description.input] = 0
						
							solution[description.input] += 1
						
						rewards[destination].solutions.append(solution)
	
	return rewards


func prepare_local_options(destinations_: Dictionary) -> void:
	var datas = []
	
	for destination in destinations_:
		for solution in destinations_[destination].solutions:
			var data = {}
			data.destination = destination
			data.solution = solution
			data.reward = destinations_[destination].reward
			data.weight = {}
			data.weight.unspent = 0
			var unspent = {}
			
			for token in Global.arr.token:
				if Global.dict.conversion.token.resource.has(token):
					var resource = Global.dict.conversion.token.resource[token]
					unspent[token] = core.gameboard.get_token_stack_value(token)
					
					if solution.has(token):
						unspent[token] -= solution[token]
					
					if Global.num.relevance.resource.has(resource):
						data.weight.unspent += unspent[token] * Global.num.relevance.resource[resource]
			
			for reward in data.reward:
				if Global.num.relevance.resource.has(reward):
					data.weight.reward = data.reward[reward] * Global.num.relevance.resource[reward]
				
				if Global.num.relevance.token.has(reward):
					data.weight.reward = data.reward[reward] * Global.num.relevance.token[reward]
				
				data.weight.total = data.weight.unspent + data.weight.reward
				datas.append(data)
	
	datas.sort_custom(func(a, b): return a.weight.total > b.weight.total)
	var destinations = {}
	
	for data in datas:
		if !destinations.has(data.destination):
			destinations[data.destination] = data
	
	for destination in destinations:
		var pathway = get_pathway(destination)
		var data = destinations[destination]
		
		
		pathway.add_tokens("input", "motion", pathway.motionvalue.get_number())
		#print(destination.index)
		
		for token in data.solution:
			pathway.add_tokens("input", token, data.solution[token])
		
		for reward in data.reward:
			if Global.arr.token.has(reward):
				pathway.add_tokens("output", reward, data.reward[reward])
			if Global.arr.resource.has(reward):
				pathway.add_resources(reward, data.reward[reward])
		
	
	for pathway in pathways.get_children():
		var destination = pathway.rooms.destination
		
		for penalty in destination.obstacle.penalty:
			pathway.add_tokens("output", penalty, destination.obstacle.penalty[penalty])
		
		pathway.sort_puts() 
		#pathway.visible = pathway.outputbox.visible
		pass


func update_continuations() -> void:
	var datas = []
	
	for pathway in pathways.get_children():
		var data = {}
		data.pathway = pathway
		data.weight = 0
		pathway.update_continuation()
