class_name RoomResource extends Resource


var maze: MazeResource:
	set = set_maze
var obstacle: ObstacleResource
var content: ContentResource
var outpost: OutpostResource
var lair: LairResource

var doors = {}

var ring: int
var order: int
var index: int
var sector: int

var position: Vector2
var backdoor: bool
var bg_color: Color


func set_maze(maze_: MazeResource) -> RoomResource:
	maze = maze_
	index = maze.rooms.size()
	maze.rooms.append(self)
	maze.ring_rooms[ring].append(self)
	
	obstacle = ObstacleResource.new()
	obstacle.room = self
	content = ContentResource.new()
	content.room = self
	return self
	
func roll_obstacle_and_content() -> void:
	var weights = {}
	weights = {}
	
	for type in Global.dict.room.content:
		weights[type] = Global.dict.room.content[type].sector[sector].rarity
	
	content.type = Global.get_random_key(weights)
	weights = {}
	
	for type in Global.dict.room.obstacle:
		weights[type] = Global.dict.room.obstacle[type].sector[sector].rarity
	
	if content.type == "empty":
		weights["empty"] *= 3
	
	obstacle.type = Global.get_random_key(weights)
	bg_color = Global.color.obstacle[obstacle.type]
	
#region color
func update_color_based_on_ring() -> void:
	if !backdoor:
		var max_h = 360.0
		var h = 0
		var odd = ring % 6
		
		match odd:
			0:
				h = 0 / max_h
			1:
				h = 210 / max_h
			2:
				h = 120 / max_h
			3:
				h = 270 / max_h
			4:
				h = 300 / max_h
			5:
				h = 60 / max_h
		
		bg_color = Color.from_hsv(h, 0.75, 1)
	
func update_color_based_on_sector() -> void:
	bg_color = Color.from_hsv(float(sector) / maze.sector_final, 0.75, 1)
#endregion
