extends MarginContainer

@onready var gameboard = $HBox/Gameboard
@onready var crossroad = $HBox/Crossroad

var nexus = null
var maze = null
var outpost = null
var room = null
var phase = null
var intelligence = {}
var empowerment = {}


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	maze = nexus.sketch.maze
	
	intelligence.room = []
	var input = {}
	input.core = self
	input.origin = null
	crossroad.set_attributes(input)
	gameboard.set_attributes(input)
	spaw_on_outpost()
	nexus.sketch.add_serif()
	
#	follow_phase()
#	follow_phase()
#
#	for _i in 6:
#		skip_phases()
#	nexus.sketch.add_serif()


func spaw_on_outpost() -> void:
	outpost = maze.outposts.get_children().pick_random()
	return_to_outpost()
	get_outpost_intelligence()


func move_in_room(room_: Polygon2D) -> void:
	room = room_
	crossroad.set_room(room)
	maze.focus_on_room(room)


func get_outpost_intelligence() -> void:
	get_intelligence(outpost.room, true)
	
	for door in outpost.room.doors:
		var room_ = outpost.room.doors[door]
		get_intelligence(room_, true)


func get_intelligence(room_: Polygon2D, free_: bool) -> void:
	intelligence.room.append(room_)
	
	if !free_:
		gameboard.change_resource_stack_value("intelligence", -1)


func solution_availability_check(solution_: Dictionary, origin_: Variant) -> bool:
	var flag = true
	var subtypes = []
	subtypes.append_array(solution_.keys())
	
	if origin_ != null:
		for token in origin_.inputTokens.get_children():
			var subtype = token.title.subtype
			
			if !subtypes.has(subtype):
				subtypes.append(subtype)
	
	for subtype in subtypes:
		var value = 0
		
		if solution_.has(subtype):
			value += solution_[subtype]
		
		if origin_ != null:
			var token = origin_.get_token("input", subtype)
			
			if token != null:
				value += origin_.get_token_stack_value("input", subtype)
		
		flag = flag and token_availability_check(subtype, value)
	
	return flag


func token_availability_check(subtype_: String, value_: int) -> bool:
	if subtype_ == "free":
		return true
	
	return gameboard.get_token_stack_value(subtype_) >= value_


func skip_phases() -> void:
#	crossroad.set_local_ambition()
#	crossroad.update_continuations()
#	crossroad.compare_continuations()
#	crossroad.reset_pathways()
#	gameboard.reset_tokens()
	for phase_ in Global.arr.phase:
		follow_phase()


func follow_pathway(pathway_: Variant) -> void:
	if pathway_ != null:
		if pathway_.crossroad.origin != null:
			pathway_.crossroad.origin.rooms.destination.passage_test(pathway_.crossroad.origin)
			#print(pathway_.crossroad.origin.rooms.destination.index)
		
		pathway_.rooms.destination.passage_test(pathway_)
		#print(pathway_.rooms.destination.index)
		
		move_in_room(pathway_.rooms.destination)
		var motion = pathway_.get_token("input", "motion")
		if motion != null:
			token_conversion(motion)
		
		for token in pathway_.outputTokens.get_children():
			token_conversion(token)
		
		for resource in pathway_.outputResources.get_children():
			apply_resource(resource)
	else:
		crossroad.reset_pathways()


func token_conversion(token_: MarginContainer) -> void:
	if token_ != null:
		var subtype = token_.title.subtype
		var input = {}
		input.proprietor = self
		input.resource = Global.dict.conversion.token.resource[subtype]
		input.stack = token_.stack.get_number() * Global.dict.conversion.token.sign[subtype]

		var resource = Global.scene.resource.instantiate()
		add_child(resource)
		resource.set_attributes(input)
		apply_resource(resource)
		remove_child(resource)
		resource.queue_free()
	else:
		print("error: token is null")


func apply_resource(resource_: MarginContainer) -> void:
	var subtype = resource_.title.subtype
	var value = resource_.stack.get_number()
	var resource = gameboard.get_resource(subtype)
	
	if resource != null:
		gameboard.change_resource_stack_value(subtype, value)
	else:
		match subtype:
			"energy":
				for _i in abs(value):
					if value > 0:
						gameboard.recharge_card()
					else:
						gameboard.overload_card()
			"spares":
				for _i in abs(value):
					if value > 0:
						gameboard.repair_card()
					else:
						gameboard.breakage_card()


func follow_phase() -> void:
	if phase == null:
		phase = Global.arr.phase.front()
	else:
		var index = (Global.arr.phase.find(phase) + 1) % Global.arr.phase.size()
		phase = Global.arr.phase[index]
	
	#print(phase)
	call(phase)


func draw_hand() -> void:
	gameboard.hand.refill()
	gameboard.hand.apply()


func get_pathways() -> void:
	crossroad.set_local_ambition()
	crossroad.update_continuations()


func choose_pathway() -> void:
	crossroad.compare_continuations()


func halt() -> void:
	gameboard.reset_tokens()
	gameboard.change_resource_stack_value("intelligence", 1)
	crossroad.tap_into_intelligence()
	
	if gameboard.available.cards.get_child_count() == 0:
		return_to_outpost()
		drones_assembly()


func return_to_outpost() -> void:
	move_in_room(outpost.room)
	var value = 120 - gameboard.get_resource_stack_value("fuel")
	gameboard.change_resource_stack_value("fuel", value)
	
	gameboard.repair_all_cards()
	gameboard.recharge_all_cards()


func empowerment_request(tokens_: Dictionary) -> void:
	for token in tokens_:
		if !empowerment.has(token):
			empowerment[token] = 0
		
		empowerment[token] += tokens_[token]


func drones_assembly() -> void:
	pass


func buy_market_card(slot_: int) -> void:
	var card = nexus.market.cards.get_child(slot_)
	nexus.market.cards.remove_child(card)
	gameboard.available.cards.add_child(card)
	card.area = gameboard.available
	card.gameboard = gameboard
	gameboard.change_resource_stack_value("mineral", card.price)
