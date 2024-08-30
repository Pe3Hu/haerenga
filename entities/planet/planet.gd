class_name Planet extends PanelContainer


@export var world: World
@export var maze: Maze

var resource: PlanetResource


func _ready() -> void:
	resource = PlanetResource.new()
	
	maze.set_resource(resource.maze).set_planet(self)
