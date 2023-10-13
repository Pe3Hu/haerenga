extends MarginContainer


@onready var destinationIcon = $HBox/Destination/Icon
@onready var destinationIndex = $HBox/Destination/Index
@onready var motionIcon = $HBox/Motion/Icon
@onready var motionValue = $HBox/Motion/Value
@onready var roomIcon = $HBox/Room/Icon
@onready var roomObstacle = $HBox/Room/Obstacle
@onready var roomRequirement = $HBox/Room/Requirement
@onready var roomContent = $HBox/Room/Content
@onready var roomValue = $HBox/Room/Value
@onready var inputBox = $HBox/Input
@onready var inputIcon = $HBox/Input/Icon
@onready var inputTokens = $HBox/Input/Tokens
@onready var outputBox = $HBox/Output
@onready var outputIcon = $HBox/Output/Icon
@onready var outputTokens = $HBox/Output/Tokens
@onready var outputResources = $HBox/Output/Resources
@onready var continuation = $HBox/Continuation

var core = null
var crossroad = null
var doors = null
var rooms = {}
var solutions = []
var rewards = {}
var medal = false


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	crossroad = input_.crossroad
	rooms.departure = input_.departure
	rooms.destination = input_.destination
	
	set_icons(input_.length)
	
	if crossroad.origin != null:
		for token in crossroad.origin.inputTokens.get_children():
			var subtype = token.title.subtype
			var value = token.stack.get_number()
			add_tokens("input", subtype, value)
		
		for token in crossroad.origin.outputTokens.get_children():
			var subtype = token.title.subtype
			var value = token.stack.get_number()
			add_tokens("output", subtype, value)
		
		for resource in crossroad.origin.outputResources.get_children():
			var subtype = resource.title.subtype
			var value = resource.stack.get_number()
			add_resources(subtype, value)


func set_icons(length_: int) -> void:
	var input = {}
	input.type = "node"
	input.subtype = "door"
	destinationIcon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.index
	destinationIndex.set_attributes(input)
	
	input = {}
	input.type = "token"
	input.subtype = "motion"
	motionValue.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = length_
	motionValue.set_attributes(input)
	
	input = {}
	input.type = "obstacle"
	input.subtype = rooms.destination.obstacle.subtype
	roomObstacle.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.obstacle.requirement
	roomRequirement.set_attributes(input)

	input = {}
	input.type = "content"
	input.subtype = rooms.destination.content.type
	roomContent.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.content.value
	roomValue.set_attributes(input)
	
	input = {}
	input.type = "node"
	input.subtype = "minus"
	inputIcon.set_attributes(input)
	
	input = {}
	input.type = "node"
	input.subtype = "plus"
	outputIcon.set_attributes(input)


func add_tokens(put_: String, subtype_: String, value_: int) -> void:
	if value_ != 0:
		var tokens = get(put_+"Tokens")
		var hbox = get(put_+"Box")
		hbox.visible = true
		var token = get_token(put_, subtype_)
		
		if token == null:
			var input = {}
			input.proprietor = self
			input.subtype = subtype_
			input.value = value_
			
			token = Global.scene.token.instantiate()
			tokens.add_child(token)
			token.set_attributes(input)
		else:
			token.change_stack(value_)


func add_resources(resource_: String, value_: int) -> void:
	if value_ != 0:
		outputBox.visible = true
		var resource = get_resource(resource_)
		
		if resource == null:
			var input = {}
			input.proprietor = self
			input.resource = resource_
			input.stack = value_
			
			resource = Global.scene.resource.instantiate()
			outputResources.add_child(resource)
			resource.set_attributes(input)
		else:
			resource.change_stack(value_)


func get_token(put_: String, subtype_: String) -> Variant:
	var tokens = get(put_+"Tokens")
	
	for token in tokens.get_children():
		if token.title.subtype == subtype_:
			return token
	
	return null


func get_token_stack_value(put_: String, subtype_: String) -> Variant:
	var token = get_token(put_, subtype_)
	
	if token != null:
		return token.stack.get_number()
	
	return null


func get_resource(subtype_: String) -> Variant:
	for resource in outputResources.get_children():
		if resource.title.subtype == subtype_:
			return resource
	
	return null


func get_resource_stack_value(subtype_: String) -> Variant:
	var resource = get_resource(subtype_)
	
	if resource != null:
		return resource.stack.get_number()
	
	return null


func sort_puts() -> void:
	var keys = ["inputTokens", "outputTokens", "outputResources"]
	
	for key in keys:
		var parent = get(key)
		var childs = []
		
		while parent.get_child_count() > 0:
			var child = parent.get_child(0)
			parent.remove_child(child)
			childs.append(child)
		
		childs.sort_custom(func(a, b): return Global.arr.output.find(a.title.subtype) < Global.arr.output.find(b.title.subtype))

		while !childs.is_empty():
			var child = childs.pop_front()
			parent.add_child(child)


func update_continuation() -> void:
	#if rooms.destination != core.room:
	continuation.visible = true
	var input = {}
	input.core = core
	input.origin = self
	continuation.set_attributes(input)
	continuation.set_room(rooms.destination)
	continuation.set_local_ambition()
