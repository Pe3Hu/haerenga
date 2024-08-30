class_name PlanetResource extends Resource


var maze: MazeResource


func _init() -> void:
	maze = MazeResource.new()
	maze.planet = self
