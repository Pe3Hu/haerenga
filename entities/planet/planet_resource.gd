class_name PlanetResource extends Resource


var maze: MazeResource
var corporations: Array[CorporationResource]

var corporation_count = 3


func _init() -> void:
	#maze = MazeResource.new()
	#maze.planet = self
	
	for _i in  corporation_count:
		var corporation = CorporationResource.new()
		corporation.set_planet(self)
