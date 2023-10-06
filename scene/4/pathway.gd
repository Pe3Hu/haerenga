extends MarginContainer


@onready var destinationicon = $HBox/Destination/Icon
@onready var destinationindex = $HBox/Destination/Index
@onready var motionicon = $HBox/Motion/Icon
@onready var motionvalue = $HBox/Motion/Value
@onready var roomicon = $HBox/Room/Icon
@onready var roomobstacle = $HBox/Room/Obstacle
@onready var roomrequirement = $HBox/Room/Requirement
@onready var roomcontent = $HBox/Room/Content
@onready var roomvalue = $HBox/Room/Value
@onready var input = $HBox/Input
@onready var inputicon = $HBox/Input/Icon
@onready var inputtokens = $HBox/Input/Tokens
@onready var output = $HBox/Output
@onready var outputicon = $HBox/Output/Icon
@onready var outputtokens = $HBox/Output/Tokens
@onready var outputresources = $HBox/Output/Resources

var doors = null
var rooms = {}


func set_attributes(input_: Dictionary) -> void:
	#door = input_.door
	rooms.departure = input_.departure
	rooms.destination = input_.destination
	
	set_icons(input_.length)


func set_icons(length_: int) -> void:
	var input = {}
	input.type = "node"
	input.subtype = "door"
	destinationicon.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.index
	destinationindex.set_attributes(input)
	
	input = {}
	input.type = "token"
	input.subtype = "motion"
	motionvalue.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = length_
	motionvalue.set_attributes(input)
	
	input = {}
	input.type = "obstacle"
	input.subtype = rooms.destination.obstacle.subtype
	roomobstacle.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.obstacle.requirement
	roomrequirement.set_attributes(input)

	input = {}
	input.type = "content"
	input.subtype = rooms.destination.content.type
	roomcontent.set_attributes(input)
	
	input = {}
	input.type = "number"
	input.subtype = rooms.destination.content.value
	roomvalue.set_attributes(input)
	
	input = {}
	input.type = "node"
	input.subtype = "minus"
	inputicon.set_attributes(input)
	
	input = {}
	input.type = "node"
	input.subtype = "plus"
	outputicon.set_attributes(input)


func add_tokens(put_: String, token_: String, value_: int) -> void:
	if value_ != 0:
		var tokens = get(put_+"tokens")
		var hbox = get(put_)
		hbox.visible = true
		var token = get_token(put_, token_)
		
		if token == null:
			var input = {}
			input.proprietor = self
			input.token = token_
			input.stack = value_
			
			token = Global.scene.token.instantiate()
			tokens.add_child(token)
			token.set_attributes(input)
		else:
			token.change_stack(value_)


func add_resources(resource_: String, value_: int) -> void:
	if value_ != 0:
		output.visible = true
		var resource = get_resource(resource_)
		
		if resource == null:
			var input = {}
			input.proprietor = self
			input.resource = resource_
			input.stack = value_
			
			resource = Global.scene.resource.instantiate()
			outputresources.add_child(resource)
			resource.set_attributes(input)
		else:
			resource.change_stack(value_)


func get_token(put_: String, token_: String) -> Variant:
	var tokens = get(put_+"tokens")
	
	for token in tokens.get_children():
		if token.title.subtype == token_:
			return token
	
	return null


func get_resource(resource_: String) -> Variant:
	for resource in outputresources.get_children():
		if resource.title.subtype == resource_:
			return resource
	
	return null


func sort_puts() -> void:
	var keys = ["inputtokens", "outputtokens", "outputresources"]
	
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
