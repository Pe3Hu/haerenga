extends MarginContainer


@onready var pathways = $Pathways

var core = null
var maze = null
var room = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	maze = core.maze


func update_room() -> void:
	room = core.room
	
	reset_pathways()


func reset_pathways() -> void:
	for pathway in pathways.get_children():
		pathways.remove_child(pathway)
		pathway.queue_free()
	
	for door in room.doors:
		var input = {}
		input.door = door
		input.departure = room
		input.destination = door.get_another_room(room)
		
		var pathway = Global.scene.pathway.instantiate()
		pathways.add_child(pathway)
		pathway.set_attributes(input)
