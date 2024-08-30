class_name ObstacleResource extends Resource


var room: RoomResource
var type: String:
	set(type_):
		type = type_
		roll_requirement()
var hazard = null
var requirement = 0
var penalty = {}
var active = true


func roll_requirement() -> void:
	var description = Global.dict.room.obstacle[type]
	var base = description.sector[room.sector].requirement
	penalty[description.token.penalty] = description.sector[room.sector].penalty
	
	if base > 0:
		var limit = floor(base * 0.25)
		var complexities = {}

		for _i in limit:
			complexities[base + _i] = int(limit - _i)
		
		requirement = Global.get_random_key(complexities)
	
func set_hazard(hazard_: Variant) -> void:
	hazard = hazard_
	
	if hazard == null:
		if room.backdoor:
			hazard = 3
			
			if room.doors.size() == 2:
				hazard += 1
		else:
			hazard = Global.get_random_hazard(room.sector)
	
	var description = Global.dict.hazard[hazard]
	requirement = ceil(description["requirement multiplier"] * requirement)
