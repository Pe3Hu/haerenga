extends MarginContainer

@onready var gameboard = $HBox/Gameboard
@onready var crossroad = $HBox/Crossroad

var nexus = null
var maze = null
var outpost = null
var room = null
var intelligence = {}


func set_attributes(input_: Dictionary) -> void:
	nexus = input_.nexus
	maze = nexus.sketch.maze
	
	intelligence.room = []
	var input = {}
	input.core = self
	input.origin = null
	crossroad.set_attributes(input)
	spaw_on_outpost()
	gameboard.set_attributes(input)
	
	#make_decision()


func spaw_on_outpost() -> void:
	outpost = maze.outposts.get_children().pick_random()
	move_in_room(outpost.room)
	maze.focus_on_room(room)
	crossroad.set_room(room)
	get_outpost_intelligence()


func move_in_room(room_: Polygon2D) -> void:
	room = room_
	maze.focus_on_room(room)


func get_outpost_intelligence() -> void:
	get_intelligence(outpost.room, true)
	
	for door in outpost.room.doors:
		var room_ = outpost.room.doors[door]
		get_intelligence(room_, true)


func get_intelligence(room_: Polygon2D, free_: bool) -> void:
	intelligence.room.append(room_)
	
	if !free_:
		var resource = gameboard.get_resource("intelligence")
		resource.stack.change_number(-1)


func solution_availability_check(solution_: Dictionary, origin_: Variant) -> bool:
	var flag = true
	var subtypes = []
	subtypes.append_array(solution_.keys())
	
	if origin_ != null:
		for token in origin_.inputtokens.get_children():
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


func expedition_check_for_continuation(destination_: Dictionary) -> bool:
	
	return false


func make_decision() -> void:
	gameboard.next_turn()
	crossroad.set_local_ambition()
	crossroad.update_continuations()
	crossroad.compare_continuations()
	crossroad.reset_pathways()
	
	gameboard.reset_tokens()


func follow_pathway(pathway_: Variant) -> void:
	if pathway_ != null:
		var a = []
		if pathway_.crossroad.origin != null:
			a.append(pathway_.crossroad.origin.rooms.destination.index)
		
		a.append(pathway_.rooms.destination.index)
		print(a)
		move_in_room(pathway_.rooms.destination)
		var subtype = {}
		var motion = pathway_.get_token("input", "motion")
		token_conversion(motion)
		
		for token in pathway_.outputtokens.get_children():
			token_conversion(token)
		
		for resource in pathway_.outputresources.get_children():
			apply_resource(resource)


func token_conversion(token_: MarginContainer) -> void:
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
			"malfunction":
				for _i in abs(value):
					if value > 0:
						gameboard.breakage_card()
					else:
						gameboard.repair_card()
