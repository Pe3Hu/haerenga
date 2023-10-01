extends Node


func _ready() -> void:
	Global.node.sketch = Global.scene.sketch.instantiate()
	Global.node.game.get_node("Layer0").add_child(Global.node.sketch)
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var value = Global.rng.randi_range(min, max)
	pass


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.maze.camera.onfocus()
			KEY_W:
				if event.is_pressed():
					Global.node.sketch.maze.move_icons("up")
			KEY_D:
				if event.is_pressed():
					Global.node.sketch.maze.move_icons("right")
			KEY_S:
				if event.is_pressed():
					Global.node.sketch.maze.move_icons("down")
			KEY_A:
				if event.is_pressed():
					Global.node.sketch.maze.move_icons("left")


func _process(delta_) -> void:
	$FPS.text = str(Engine.get_frames_per_second())
