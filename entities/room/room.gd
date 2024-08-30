class_name Room extends Node2D


@export var bg_rect: TextureRect
@export var label_index: Label
@export var label_requiremen: Label

var maze: Maze:
	set = set_maze
var resource: RoomResource:
	set = set_resource


func set_maze(maze_: Maze) -> Room:
	maze = maze_
	position = resource.position
	maze.rooms.add_child(self)
	return self
	
func set_resource(resource_: RoomResource) -> Room:
	resource = resource_
	label_index.text = str(resource.index)
	bg_rect.modulate = resource.bg_color
	
	if resource.outpost == null and resource.lair == null:
		label_requiremen.visible = true
		label_requiremen.text = str(resource.obstacle.requirement)
	
	return self
