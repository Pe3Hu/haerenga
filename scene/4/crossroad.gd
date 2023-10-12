extends MarginContainer


@onready var tree = $HBox/Tree
@onready var pathways = $HBox/Pathways
@onready var departureicon = $HBox/Departure/Icon
@onready var departureindex = $HBox/Departure/Index


var core = null
var origin = null
var room = null
var impediments = {}


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	origin = input_.origin
	
	var input = {}
	input.type = "node"
	input.subtype = "door"
	departureicon.set_attributes(input)
	
	input = {}
	input.crossroad = self
	tree.set_attributes(input)


func set_room(room_: Polygon2D) -> void:
	room = room_
	
	var input = {}
	input.type = "number"
	input.subtype = room.index
	departureindex.set_attributes(input)
	reset_pathways()


func reset_pathways() -> void:
	impediments = {}
	
	while pathways.get_child_count() > 0:
		var pathway = pathways.get_child(0)
		pathways.remove_child(pathway)
		pathway.queue_free()


func set_local_ambition() -> void:
	fill_pathways()
	get_local_solutions()
	get_local_rewards()
	prepare_local_options()


func fill_pathways() -> void:
	tree.set_shortest_routes_based_on_dijkstra()
	var destinations = tree.destinations.keys()
	destinations.sort_custom(func(a, b): return  tree.destinations[a].length <  tree.destinations[b].length)
	
	for destination in destinations:
		var flag = true
		
		if origin != null:
			if origin.rooms.destination == destination:
				flag = false
		
		if flag:
			var input = {}
			input.length = tree.destinations[destination].length
			
			if core.token_availability_check("motion", input.length):
				input.core = core
				input.crossroad = self
				input.departure = room
				input.destination = destination
				
				var pathway = Global.scene.pathway.instantiate()
				pathways.add_child(pathway)
				pathway.set_attributes(input)
		#pathway.add_tokens("input", "motion", input.length)


func get_local_solutions() -> void:
	var destinations = {}
	
	for pathway in pathways.get_children():
		var destination = pathway.rooms.destination
		
		if core.intelligence.room.has(destination):
			var solutions = []
			
			#if destination.obstacle.subtype != "empty" and destination.obstacle.active:
			solutions.append_array(destination.obstacle.get_solutions())
		
			for solution in solutions:
				if !solution.has("motion"):
					solution["motion"] = 0
				
				solution["motion"] += pathway.motionvalue.get_number()
				
				if core.solution_availability_check(solution, origin):
					#solution["motion"] -= pathway.motionvalue.get_number()
					pathway.solutions.append(solution)
			
					if destination.obstacle.subtype != "empty" and !pathway.medal:
						pathway.medal = true
		
		if !pathway.medal and destination.obstacle.subtype != "empty":
			if !impediments.has(destination.obstacle):
				impediments[destination.obstacle] = []
			
			impediments[destination.obstacle].append(pathway)
		
		#print([destination.index, destination.obstacle.subtype, pathway.solutions])


func get_local_rewards() -> void:
	for pathway in pathways.get_children():
		var destination = pathway.rooms.destination
		
		if destination.content.type != "empty":
			var description = Global.dict.room.content[destination.content.type]
			
			for solution in pathway.solutions:
				var fee = 1
			
				if solution.has(description.input):
					fee += solution[description.input]
				
				if description.input == "free" or core.token_availability_check(description.input, fee):
					if description.input != "free":
						if !solution.has(description.input):
							solution[description.input] = 0
					
						solution[description.input] += 1
					
					pathway.rewards[solution] = {}
					pathway.rewards[solution][description.output] = description.sector[destination.sector].value


func prepare_local_options() -> void:
	var datas = []
	
	for pathway in pathways.get_children():
		if !pathway.rewards.is_empty():
			for solution in pathway.rewards:
				var data = {}
				data.pathway = pathway
				data.destination = pathway.rooms.destination
				data.solution = solution
				data.reward = pathway.rewards[solution]
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
			data.pathway = pathway
			data.destination = pathway.rooms.destination
			data.solution = {}
			data.solution["motion"] = data.pathway.motionvalue.get_number()
			data.reward = {}
			data.weight = {}
			data.weight.total = 0

			datas.append(data)
	
	datas.sort_custom(func(a, b): return a.weight.total > b.weight.total)
	var best = {}
	
	for data in datas:
		if !best.has(data.pathway):
			best[data.pathway] = data
	
	for pathway in best:
		var data = best[pathway]
		#pathway.add_tokens("input", "motion", pathway.motionvalue.get_number())
		#print([pathway.rooms.departure.index, pathway.rooms.destination.index, pathway.motionvalue.get_number()])
		
		for token in data.solution:
			pathway.add_tokens("input", token, data.solution[token])
		
		for reward in data.reward:
			if Global.arr.token.has(reward):
				pathway.add_tokens("output", reward, data.reward[reward])
			if Global.arr.resource.has(reward):
				pathway.add_resources(reward, data.reward[reward])
	
		for penalty in data.destination.obstacle.penalty:
			pathway.add_tokens("output", penalty, data.destination.obstacle.penalty[penalty])
		
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
	var options = []
	options.append_array(pathways.get_children())
	
	for pathway in pathways.get_children():
		options.append_array(pathway.continuation.pathways.get_children())
	
	
	for pathway_ in options:
		var data = {}
		data.index = pathway_.rooms.destination.index
		data.pathway = pathway_
		data.weight = {}
		data.weight.output = 0
		data.weight.milestone = pathway_.rooms.destination.milestones[core.outpost.room] * 2
		data.weight.total = 0
		data.weight.unspent = 0
		var subtype = {}
		#print(data.index)
		
		for token in core.gameboard.tokens.get_children():
			subtype.token = token.title.subtype
			
			#if unspent[subtype.token] > 0:
			#unspent[subtype.token] = core.gameboard.get_token_stack_value(subtype.token)
			
			if Global.dict.conversion.token.sign[subtype.token] > 0:
				subtype.resource = Global.dict.conversion.token.resource[subtype.token]
				var unspent = core.gameboard.get_token_stack_value(subtype.token)
				
				if unspent > 0:
					#print(["unspent", subtype.token, subtype.resource, unspent])
					data.weight.unspent += unspent * Global.num.relevance.resource[subtype.resource]
					var spent = pathway_.get_token_stack_value("input", subtype.token)
				
					if Global.num.relevance.resource.has(subtype.resource) and spent != null:
						#print(["spent", subtype.token, subtype.resource,spent])
						data.weight.unspent -= spent * Global.num.relevance.resource[subtype.resource]
			
				#print(["weight", data.weight.unspent])
		
		for resource in pathway_.outputresources.get_children():
			subtype.resource = resource.title.subtype
			
			if Global.num.relevance.resource.has(subtype.resource):
				data.weight.output += pathway_.get_resource_stack_value(subtype.resource) * Global.num.relevance.resource[subtype.resource]
		
		for token in pathway_.outputtokens.get_children():
			subtype.token = token.title.subtype
			
			if Global.num.relevance.token.has(subtype.token):
				data.weight.output += pathway_.get_token_stack_value("output", subtype.token) * Global.num.relevance.token[subtype.token]
		
		data.weight.total = data.weight.unspent + data.weight.output + data.weight.milestone
		
		if pathway_.medal:
			data.weight.total *= 2
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.weight.total > b.weight.total)
	
	#for data_ in datas:
	#	print(data_)
	var pathway = datas.front().pathway
	
	if !pathway.medal:
		impediment_analysis()
	
	core.follow_pathway(pathway)


func impediment_analysis() -> void:
	var datas = []
	
	for obstacle in impediments:
		var solutions = obstacle.get_solutions()
		var data = {}
		data.tokens = {}
		data.tokens.necessary = {}
		data.tokens.available = core.gameboard.get_tokens_as_dict()
		
		for solution in solutions:
			for token in solution:
				if !data.tokens.necessary.has(token):
					data.tokens.necessary[token] = 0.0
				
				data.tokens.necessary[token] += solution[token]
		
		for token in data.tokens.necessary:
			data.tokens.necessary[token] /= solutions.size()
		
		var motion = 0
		
		for pathway in impediments[obstacle]:
			motion = max(motion, pathway.motionvalue.get_number())
		
		data.tokens.available["motion"] -= motion
		print([obstacle.room.index, data.tokens])
		
		for token in data.tokens.necessary:
			var value = data.tokens.necessary[token] 
			
			if data.tokens.available.has(token):
				value -= data.tokens.available[token]
			
			if value > 0:
				data.tokens.necessary[token] = value
			else:
				data.tokens.necessary.erase(token)
		
		datas.append(data)
	
	var empowerment = {}
	
	if datas.is_empty():
		empowerment["motion"] = 3
	else:
		for data in datas:
			for token in data.tokens.necessary:
				if !empowerment.has(token):
					empowerment[token] = 0.0
				
				empowerment[token] += data.tokens.necessary[token]
		
		for token in empowerment:
			empowerment[token] /= datas.size()
	
	core.empowerment_request(empowerment)


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
