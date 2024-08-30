class_name Maze extends SubViewportContainer


@export var subViewport: SubViewport
@export var node2Ds: Node2D
@export var rooms: Node2D
@export var doors: Node2D
@export var camera: MazeCamera

@onready var room_scene = preload("res://entities/room/room.tscn")
@onready var door_scene = preload("res://entities/door/door.tscn")

var planet: Planet:
	set = set_planet
var resource: MazeResource:
	set = set_resource


func set_planet(planet_: Planet) -> Maze:
	planet = planet_
	
	init_rooms()
	init_doors()
	
	camera.resource = resource.camera
	node2Ds.position += subViewport.size * 0.5
	#camera.zoom = Vector2.ONE * 0.55#0.5 
	camera.set_room(resource.gamer_outpost)
	return self
	
func set_resource(resource_: MazeResource) -> Maze:
	resource = resource_
	return self
	
func init_rooms() -> void:
	for room_resource in resource.rooms:
		var room = room_scene.instantiate()
		room.set_resource(room_resource).set_maze(self)
	
func init_doors() -> void:
	for door_resource in resource.doors:
		var door = door_scene.instantiate()
		door.set_resource(door_resource).set_maze(self)
	
func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_MINUS:
				if event.is_pressed() && !event.is_echo():
					camera.zoom_it("-")
			KEY_PLUS:
				if event.is_pressed() && !event.is_echo():
					camera.zoom_it("+")
