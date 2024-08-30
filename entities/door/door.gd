class_name Door extends Line2D


@export var bg_rect: ColorRect
@export var label_length: Label

var maze: Maze:
	set = set_maze
var resource: DoorResource:
	set = set_resource


func set_maze(maze_: Maze) -> Door:
	maze = maze_
	maze.rooms.add_child(self)
	
	for room in resource.rooms:
		add_point(room.position)
		label_length.position += room.position
	
	label_length.position /= resource.rooms.size()
	label_length.position -= Vector2.ONE * resource.font_size / 2
	return self
	
func set_resource(resource_: DoorResource) -> Door:
	resource = resource_
	label_length.text = str(resource.length)
	#bg_rect.color = resource.bg_color
	return self
