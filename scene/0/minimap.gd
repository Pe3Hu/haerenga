extends MarginContainer


var maze = null


func set_attributes(input_: Dictionary) -> void:
	maze = input_.maze
	maze.camera.zoom = Vector2.ONE * 0.5

#	for polygons in maze.polygons.get_children():
#		for polygon in polygons.get_children():
#			pass
