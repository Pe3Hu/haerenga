class_name OutpostResource extends Resource


var room: RoomResource
var coverage


#func init_milestones() -> void:
	#var tide = {}
	#tide.n = 0
	#tide.high = []
	#tide.low = [room]
	#coverage = 10
	#
	#while tide.n < coverage:
		#for room_ in tide.low:
			#room_.milestones[room] = tide.n
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
