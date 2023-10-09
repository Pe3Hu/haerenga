extends MarginContainer


@onready var tree = $Tree
@onready var pathways = $Pathways

var core = null
var origin = null
var room = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	origin = input_.origin
	
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


func set_local_ambition() -> void:
	fill_pathways()
	var solutions = get_local_solutions()
	var rewards = get_local_rewards(solutions)
	prepare_local_options(rewards)


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


func get_local_solutions() -> Dictionary:
	var destinations = {}
	
	for pathway in pathways.get_children():
		var destination = pathway.rooms.destination
		destinations[destination] = []
		var solutions = []
		
		if core.intelligence.room.has(destination):
			if destination.obstacle.subtype != "empty" and destination.obstacle.active:
				solutions = destination.obstacle.get_solutions()
		
		if !solutions.is_empty():
			for solution in solutions:
				if !solution.has("motion"):
					solution["motion"] = 0
				
				solution["motion"] += pathway.motionvalue.get_number()
			
#				for token in pathway.inputtokens.get_children():
#					if !solution.has(token.title.subtype):
#						solution[token.title.subtype] = 0
					
					#solution[token.title.subtype] += pathway.get_token_stack_value("input", token.title.subtype)
				
				if core.solution_availability_check(solution, origin):
					solution["motion"] -= pathway.motionvalue.get_number()
					destinations[destination].append(solution)
	
	return destinations


func get_local_rewards(destinations_: Dictionary) -> Dictionary:
	var rewards = {}
	
	for destination in destinations_:
		rewards[destination] = {}
		rewards[destination].reward = {}
		rewards[destination].solutions = []
		rewards[destination].free = false
		
		if destination.content.active:
			var description = Global.dict.room.content[destination.content.type]
			
			if description.output != "no":
				rewards[destination].free = description.input == "free"
				rewards[destination].reward[description.output] = description.sector[destination.sector].value
				
				#rewards[destination].reward.resource = description.output
				#rewards[destination].reward.value = description.sector[destination.sector].value
				
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
		if !destinations_[destination].solutions.is_empty():#destination.obstacle.subtype != "empty" and destination.obstacle.active:
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
		else:
			var data = {}
			data.destination = destination
			data.solution = {}
			data.reward = {}
			data.weight = {}
			data.weight.total = 0
			
			if destination.obstacle.subtype == "empty" and destination.obstacle.active and destinations_[destination].free:
				data.reward = destinations_[destination].reward
			
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
		#print([pathway.rooms.departure.index, pathway.rooms.destination.index, pathway.motionvalue.get_number()])
		
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


func get_pathway(destination_: Polygon2D) -> Variant:
	for pathway in pathways.get_children():
		if pathway.rooms.destination == destination_:
			return pathway
	
	return null


func update_continuations() -> void:
	for pathway in pathways.get_children():
		pathway.update_continuation()


func compare_continuations() -> void:
	var datas = []
	var data = {}
	data.index = core.room.index
	data.pathway = null
	data.weight = {}
	data.weight.output = 0
	data.weight.unspent = 0
	#data.weight.distance = 0
	
	var unspent = {}
	var subtype = {}
	
	for token in core.gameboard.tokens.get_children():
		subtype.token = token.title.subtype
		unspent[subtype.token] = core.gameboard.get_token_stack_value(subtype.token)
		
		if unspent[subtype.token] > 0:
			if Global.dict.conversion.token.sign[subtype.token] > 0:
				subtype.resource = Global.dict.conversion.token.resource[subtype.token]
				
				if Global.num.relevance.resource.has(subtype.resource):
					data.weight.unspent += unspent[subtype.token] * Global.num.relevance.resource[subtype.resource]
	
	data.weight.total = data.weight.unspent
	datas.append(data)
	
	var options = []
	options.append_array(pathways.get_children())
	
	for pathway in pathways.get_children():
		options.append_array(pathway.continuation.pathways.get_children())
	
	for pathway_ in options:
		data = {}
		data.index = pathway_.rooms.destination.index
		data.pathway = pathway_
		data.weight = {}
		data.weight.output = 0
		#data.weight.distance = 0
		data.weight.total = 0
		data.weight.unspent = 0
		subtype = {}
		
		for token in core.gameboard.tokens.get_children():
			subtype.token = token.title.subtype
			
			if unspent[subtype.token] > 0:
			#unspent[subtype.token] = core.gameboard.get_token_stack_value(subtype.token)
			
				if Global.dict.conversion.token.sign[subtype.token] > 0:
					subtype.resource = Global.dict.conversion.token.resource[subtype.token]
					data.weight.unspent += unspent[subtype.token] * Global.num.relevance.resource[subtype.resource]
					var spent = pathway_.get_token_stack_value("input", subtype.token)
				
					if Global.num.relevance.resource.has(subtype.resource) and spent != null:
						data.weight.unspent -= spent * Global.num.relevance.resource[subtype.resource]
		
		for resource in pathway_.outputresources.get_children():
			subtype.resource = resource.title.subtype
			
			if Global.num.relevance.resource.has(subtype.resource):
				data.weight.output += pathway_.get_resource_stack_value(subtype.resource) * Global.num.relevance.resource[subtype.resource]
		
		for token in pathway_.outputtokens.get_children():
			subtype.token = token.title.subtype
			
			if Global.num.relevance.token.has(subtype.token):
				data.weight.output += pathway_.get_token_stack_value("output", subtype.token) * Global.num.relevance.token[subtype.token]
		
		data.weight.total = data.weight.unspent + data.weight.output
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.weight.total > b.weight.total)

	var pathway = datas.front().pathway
	core.follow_pathway(pathway)


func tap_into_intelligence() -> void:
	var options = []
	
	for door in room.doors:
		var neighbor = room.doors[door]
		if !core.intelligence.room.has(neighbor):
			options.append(neighbor)
	
	while !options.is_empty() and core.gameboard.get_resource_stack_value("intelligence") > 0:
		apply_intelligence(options)


func apply_intelligence(rooms_: Array) -> void:
	var option = rooms_.pick_random()
	rooms_.erase(option)
	core.get_intelligence(option, false)
	option.update_colors_based_on_core_intelligence(core)
