class_name ContentResource extends Resource


var room: RoomResource

var type: String:
	set(type_):
		type = type_
		value = Global.dict.room.content[type].sector[room.sector].value
var value: int
var active: bool = true
var color: Color


func update_color_based_on_core_intelligence(core_) -> void:
	if core_ != null:
		if core_.intelligence.room.has(room):
			set_default_color()
			return
	
	color = Global.color.content["unknown"]
	
func set_default_color() -> void:
	color = Global.color.content[type]
	
func deactivate() -> void:
	if type != "empty":
		print([room.index, "deactivate", type])
		active = false
		value = 0
		type = "empty"
		set_default_color()
