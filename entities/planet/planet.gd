class_name Planet extends PanelContainer


@export var world: World
@export var maze: Maze
@export var player_corporation: Corporation

var resource: PlanetResource


func _ready() -> void:
	resource = PlanetResource.new()
	
	player_corporation.set_resource(resource.corporations[0]).set_planet(self)
	#maze.set_resource(resource.maze).set_planet(self)
	pass
