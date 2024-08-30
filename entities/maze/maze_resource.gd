class_name MazeResource extends Resource


var planet: PlanetResource:
	set = set_planet

var rooms: Array[RoomResource]
var doors: Array[DoorResource]
var camera: CameraResource

var ring_types: Array
var ring_rooms: Array

var equals = {}
var corners = {}
var sectors = {}

var ring_radius = 50
var ring_segment = 11

var room_radius = 8

var sector_primary = 4
var sector_final = 3

var lair_room: RoomResource
var gamer_outpost: RoomResource
var wagon_outpost: RoomResource
var viewport_size = Vector2(512, 512)
var shift = false


func set_planet(planet_: PlanetResource) -> MazeResource:
	planet = planet_
	camera = CameraResource.new()
	camera.maze = self
	init_rooms()
	update_doors()
	update_size()
	init_sectors()
	init_outposts()
	init_room_obstacles_and_contents()
	init_obstacle_hazards()
	return self
	
func init_rooms() -> void:
	ring_rooms.clear()
	ring_types.clear()
	
	var types = [
		"triple",
		"single",
		"triple",
		"equal",
		"trapeze",
		"equal",
		"double",
		"equal",
		"single",
		"equal",
		"double",
		"equal",
		"single",
		"equal",
		"single"
	]
	
	add_room(0, 0)
	
	for type in types:
		add_ring(type)
	
	lair_room = rooms[0]
	lair_room.lair = LairResource.new()
	lair_room.lair.room = lair_room
	
func add_ring(type_: String) -> void:
	if ring_segment < ring_rooms.back().size() / 3:
			return
	
	var n = ring_rooms.back().size()
	
	if ring_types.size() <= 1:
		if n == 0:
			n = 1
		
		match type_:
			"triple":
				n *= 3
	else:
		var parents = ring_rooms.back().size() / 3 - 1
		var childs = null
		
		match type_:
			"triple":
				childs = parents * 3
			"double":
				childs = parents * 2
			"single":
				childs = parents + 1
			"equal":
				childs = parents
				shift = !shift
				
				if ring_types.back() == "equal":
					equals[equals.keys().back()].append(ring_types.size())
				else:
					equals[ring_types.size()] = [ring_types.size()]
			"trapeze":
				if parents % 2 == 1:
					childs = (parents / 2) * 3 + 2
				else:
					return
		
		if ring_segment < childs / 3:
			return
		
		n = (childs + 1) * 3
	
	ring_types.append(type_)
	ring_rooms.append([])
	var segment = n / 3
	var angle = {}
	angle.step = PI * 2 / n
	
	for _j in n:
		angle.current = angle.step * _j - PI / 2
		
		if type_ == "equal":
			var sign_ = -1
			
			if !shift:
				sign_ = 0
			
			angle.current += sign_ * angle.step / 2
			
		add_room(angle.current, segment)
	
	add_doors(type_)

func add_room(angle_: float, segment_: int) -> void:
	var room_resource = RoomResource.new()
	
	if ring_rooms.size() > 0:
		room_resource.ring = ring_rooms.size() - 1
	else:
		room_resource.ring  = 0
		ring_rooms.append([])
		ring_types.append(null)
	
	room_resource.position = Vector2.from_angle(angle_) * ring_radius * room_resource.ring
	room_resource.order = ring_rooms[room_resource.ring].size()
	room_resource.backdoor = false

	if room_resource.ring > 1:
		if  room_resource.order % segment_ == 0:
			room_resource.backdoor = true
	
	room_resource.maze = self

func add_doors(type_: String) -> void:
	var n = ring_rooms.size() - 1
	var k = 2
	var parents = ring_rooms[n - 1]
	var childs = ring_rooms[n]
	var segment = {}
	segment.parent = parents.size() / 3
	segment.child = childs.size() / 3
	var index = {}
	
	for _i in 3:
		#connect backdoor
		var a = parents[_i * segment.parent]
		var b = childs[_i * segment.child]
		connect_rooms(a, b, "backdoor")
	
		#connect lift
		if ring_types[n - 1] == "equal":# and type_ != "triple":
			var l = 2
			
			if type_ == "single":
				var m = 0
				
				for equal in equals:
					m += equals[equal].size()
				
				if m % 2 == 0:
					l = 0
			
			for _j in l:
				segment.elder = ring_rooms[n - 2].size() / 3
				index.elder = _i * segment.elder
				index.child = _i * segment.child
				
				if _j % 2 == 0:
					index.elder += segment.elder - 1
					index.child += segment.child - 1
				else:
					segment.elder = ring_rooms[n - 2].size() / 3
					index.elder += 1
					index.child += 1
			
				a = ring_rooms[n - 2][index.elder]
				b = childs[index.child]
				connect_rooms(a, b, "lift")
		
		#connect segment
		if n == 2:
			for _j in 2:
				index.parent = (_i + _j) * segment.parent % parents.size()
				index.child = _i * segment.child  + 1
				a = parents[index.parent]
				b = childs[index.child]
				connect_rooms(a, b, "letter")
		else:
			for _j in segment.parent - 1:
				index.parent = _i * segment.parent + _j + 1
				a = parents[index.parent]
				
				match type_:
					"single":
							for _k in k:
								index.child = _i * segment.child + _j + _k + 1
								b = childs[index.child]
								connect_rooms(a, b, "letter")
					"double":
						for _k in k:
							index.child =  _i * segment.child + _j * k + _k + 1
							b = childs[index.child]
							connect_rooms(a, b, "letter")
					"triple":
						k = 3
						
						for _k in k:
							index.child =  _i * segment.child + _j * k + _k + 1
							b = childs[index.child]
							connect_rooms(a, b, "letter")
					"trapeze":
						if _j % 2 == 1:
							index.child = _i * segment.child + (_j / 2 + 1) * (k + 1)
							b = childs[index.child]
							connect_rooms(a, b, "letter")
						else:
							for _k in k:
								index.child = _i * segment.child + (_j / 2) * (k + 1) + _k + 1
								b = childs[index.child]
								connect_rooms(a, b, "letter")
					"equal":
						for _k in k:
							index.child = (_i * segment.child + _j + _k) % childs.size()
							
							if shift:
								index.child = (index.child + 1) % childs.size()
							
							b = childs[index.child]
							
							if !b.backdoor:
								connect_rooms(a, b, "letter")
	
	#connect ring
	if n > 2:
		for _i in childs.size():
			var a = childs[_i]
			var b = childs[(_i + 1) % childs.size()]
			
			if !(type_ == "equal" and (a.backdoor or b.backdoor)):
				connect_rooms(a, b, "floor")
	
func connect_rooms(a_: RoomResource, b_: RoomResource, type_: String) -> void:
	if !a_.doors.has(b_):
		var door_resource = DoorResource.new()
		door_resource.type = type_
		door_resource.rooms = [a_, b_]
		door_resource.maze = self
	
func update_size() -> void:
	corners = {}
	corners.leftop = Vector2(rooms[0].position)
	corners.rightbot = Vector2()
	
	for room in rooms:
		corners.leftop.x = min(room.position.x, corners.leftop.x)
		corners.leftop.y = min(room.position.x, corners.leftop.y)
		corners.rightbot.x = max(room.position.x, corners.rightbot.x)
		corners.rightbot.y = max(room.position.x, corners.rightbot.y)
	
func update_doors() -> void:
	var intersections = []
	
	for ring in ring_rooms:
		for room in ring:
			for door in room.doors:
				if door.type == "lift" and door != null:
					for room_door in room.doors:
						if door != null:
							var neighbor_room = room.doors[room_door]
							
							for neighbor_door in neighbor_room.doors:
								if door != null:
									var vertexs = [door.get_points(), []]
									
									for vertex in neighbor_door.get_points():
										if !vertexs[0].has(vertex):
											vertexs[1].append(vertex)
									
									if vertexs[1].size() == 2:
										if Global.check_lines_intersection(vertexs):
											if !door.intersections.has(neighbor_door):
												door.intersections.append(neighbor_door)
											
											if !intersections.has(door):
												intersections.append(door)
	
	for door in intersections:
		var flag = true
		var datas = []
		var data = {}
		data.door = door
		data.begin = door.ring.begin
		datas.append(data)
		
		if !door.intersections.is_empty():
			for intersection in door.intersections:
				if intersection.type == "lift":
					data = {}
					data.door = intersection
					data.begin = intersection.ring.begin
					datas.append(data)
				else:
					flag = false
			
			if !flag:
				pass
				door.collapse()
			else:
				datas.sort_custom(func(a, b): return a.begin > b.begin)
				var door_ = datas.front().door
				
				for intersection in door_.intersections:
					intersection.intersections.erase(self)
				intersections.erase(door_)
				door_.collapse()
	
func init_sectors() -> void:
	var datas = {}
	var total = 0
	var sectors_ = {}
	
	for ring in ring_rooms.size():
		datas[ring] = ring_rooms[ring]
		total += ring_rooms[ring].size()
	
	var ring = 0
	
	for _i in sector_primary:
		sectors_[_i] = []
		
		while sectors_[_i].size() + ring_rooms[ring].size() < total / sector_primary:
			sectors_[_i].append_array(ring_rooms[ring])
			datas.erase(ring)
			ring += 1
	
	while !datas.keys().is_empty():
		var key = datas.keys().front()
		sectors_[sector_primary - 1].append_array(ring_rooms[key])
		datas.erase(key)
	
	for sector in sector_final:
		sectors[sector] = []
	
	for sector in sector_primary:
		if sector == 0: 
			sectors[sector].append_array(sectors_[sector])
		elif sector == sector_primary - 1:
			sectors[sector_final - 1].append_array(sectors_[sector_primary - 1])
		else:
			sectors[1].append_array(sectors_[sector])
		
	for sector in sectors:
		for room in sectors[sector]:
			room.sector = sector
	
	for door in doors:
		door.roll_length()
	
func init_outposts() -> void:
	var options = []
	var ring = ring_rooms.size() - 1
	var remoteness = {}
	var backdoors = []
	
	for room in ring_rooms[ring]:
		if room.backdoor:
			options.append([])
			backdoors.append(room)
		else:
			var option = options.back()
			option.append(room)
			remoteness[room] = round(viewport_size.length() / 10)
	
	for backdoor in backdoors:
		for room in ring_rooms[ring]:
			if remoteness.has(room):
				var d = round(room.position.distance_to(backdoor.position) / 10)
				remoteness[room] = min(d, remoteness[room])
	
	for options_ in options:
		var datas = {}
		
		for room in options_:
			datas[room] = remoteness[room]
		
		var room = Global.get_random_key(datas)
		room.outpost = OutpostResource.new()
		room.outpost.room = room
	
		if gamer_outpost == null:
			gamer_outpost = room
	
func init_room_obstacles_and_contents() -> void:
	for sector in sectors:
		for room in sectors[sector]:
			if room.outpost == null and room.lair == null:
				room.roll_obstacle_and_content()
	
func init_obstacle_hazards() -> void:
	var max_hazard = 6 
	lair_room.obstacle.set_hazard(max_hazard)
	
	for door in lair_room.doors:
		var room = lair_room.doors[door]
		room.obstacle.set_hazard(max_hazard - 1)
		
		for door_ in room.doors:
			var room_ = room.doors[door_]
			
			if room_.obstacle.hazard == null:
				room_.obstacle.set_hazard(max_hazard - 2)
