extends Node


func _ready() -> void:
	Global.node.sketch = Global.scene.sketch.instantiate()
	Global.node.game.get_node("Layer0").add_child(Global.node.sketch)
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var value = Global.rng.randi_range(min, max)
	
	Global.node.sketch.print_serifs()
	pass


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.nexus.cores.get_child(0).follow_phase()
			KEY_1:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.nexus.cores.get_child(0).skip_phases()
			KEY_W:
				if event.is_pressed():
					Global.node.sketch.maze.camera.move_camera("up")
			KEY_D:
				if event.is_pressed():
					Global.node.sketch.maze.camera.move_camera("right")
			KEY_S:
				if event.is_pressed():
					Global.node.sketch.maze.camera.move_camera("down")
			KEY_A:
				if event.is_pressed():
					Global.node.sketch.maze.camera.move_camera("left")
			KEY_Q:
				if event.is_pressed():
					Global.node.sketch.maze.camera.zoom_it("+")
			KEY_E:
				if event.is_pressed():
					Global.node.sketch.maze.camera.zoom_it("-")
			KEY_Z:
				if event.is_pressed():
					Global.node.sketch.nexus.cores.get_child(0).crossroad.shift_visible_pathway(1)
			KEY_C:
				if event.is_pressed():
					Global.node.sketch.nexus.cores.get_child(0).crossroad.shift_visible_pathway(-1)
			KEY_X:
				if event.is_pressed():
					Global.node.sketch.nexus.cores.get_child(0).crossroad.set_pathways_visible(true)


func _process(delta_) -> void:
	$FPS.text = str(Engine.get_frames_per_second())
