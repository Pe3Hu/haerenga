class_name World extends Node


@export var planet: Planet
@export var blabla: int = 0:
	set(blabla_):
		blabla = blabla_
	get:
		return blabla


func _ready() -> void:
	#datas.filter(func (a): return true)
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	#await get_tree().physics_frame
	pass


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					pass


#var waffle: waffleResource:
	#set = set_waffle
#
#
#func set_waffle(waffle_: waffleResource) -> ShipResource:
	#waffle = waffle_
	#waffle.ships.append(self)
	#return self
