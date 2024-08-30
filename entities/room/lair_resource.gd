class_name LairResource extends Resource


var room: RoomResource
var coverage


#func init_milestones() -> void:
	#var tide = {}
	#tide.n = 0
	#tide.high = []
	#tide.low = [room]
	#
	#coverage = maze.rings.room.size()
	#
	#while tide.n < coverage:
		#for room_ in tide.low:
			#room_.milestones[room] = coverage - tide.n
			#
			#var input = {}
			#input.type = "number"
			#input.subtype = room_.milestones[room]
			#
			#var icon = Global.scene.icon.instantiate()
			#maze.iTide.add_child(icon)
			#icon.set_attributes(input)
			#icon.position = room_.position
			#
			#for door in room_.doors:
				#var neighbor = room_.doors[door]
				#
				#if !neighbor.milestones.has(room) and !tide.high.has(neighbor) and !tide.low.has(neighbor):
					#tide.high.append(neighbor)
			#
		#tide.low = []
		#tide.low.append_array(tide.high)
		#tide.high = []
		#tide.n += 1 
