extends Node2D

export (int) var grid_width = 10
export (int) var grid_heigth = 20
export (int) var cell_size = 64
export (NodePath) var grid_path
export (NodePath) var timer_path

var bounds
var shapes
var tile_id
signal killed

var grid : TileMap
var timer : Timer

var move_counter
export var move_cooldown = 0.07

var blocks = [["Block1", "Block2", "Block3", "Block4"],
				["Block5", "Block6", "Block7", "Block8"],
				["Block9", "Block10", "Block11", "Block12"],
				["Block13", "Block14", "Block15", "Block16"]]

var current_shape = 0

func _ready():
	grid = get_node(grid_path)
	timer = get_node(timer_path)
	timer.connect("timeout", self, "process_timer")
	move_counter = 0


func _process(delta):
	# Rotate
	var rot_dir = 0
	if Input.is_action_just_pressed("rotate_left"):
		rot_dir += 1
	elif Input.is_action_just_pressed("rotate_right"):
		rot_dir -= 1
	if rot_dir == 1:
		next_shape()
	elif rot_dir == -1:
		prev_shape()
	
	# Move
	move_counter -= delta
	if move_counter <= 0:
		var move_dir = 0
		if Input.is_action_pressed("ui_left"):
			move_dir -= 1
		elif Input.is_action_pressed("ui_right"):
			move_dir += 1
		if move_dir == 1 or move_dir == -1 :
			position.x += cell_size * move_dir
			if not check_shape():
				position.x -= cell_size * move_dir
			else:
				move_counter = move_cooldown
		position.x = clamp(position.x, 
						grid.position.x - (bounds[current_shape][0] * cell_size) , 
						grid.position.x + (grid_width * cell_size) - 
							(bounds[current_shape][1] * cell_size))
		
	# Drop
	if Input.is_action_just_pressed("ui_select"):
		timer.stop()
		timer.wait_time = 0.01
		timer.start()					


func next_shape():
	var shape = (current_shape - 1) % 4
	change_shape(shape)


func prev_shape():
	var shape = (current_shape + 1) % 4
	change_shape(shape)


func change_shape(shape):
	var old_shape = current_shape
	current_shape = shape
	
	if not check_shape():
		current_shape = old_shape
	else:
		var mat = shapes[current_shape]
		for row in range(4):
			for col in range(4):
				if mat[row][col] == 1:
					get_node(blocks[row][col]).visible = true
				else:
					get_node(blocks[row][col]).visible = false


func clear_shape():
	for row in range(4):
		for col in range(4):
			get_node(blocks[row][col]).visible = false


func check_shape():
	var grid_position = grid.world_to_map(position)
	var shape = shapes[current_shape]
	
	for row in range(4):
		for col in range(4):
			if (shape[row][col] != 0 and 
				(grid.get_cell(col + grid_position.x, row + grid_position.y) != TileMap.INVALID_CELL or 
				row + grid_position.y >= grid_heigth)):
				return false
	return true

func kill_block():
	var grid_position = grid.world_to_map(position)
	var shape = shapes[current_shape]
	
	for row in range(4):
		for col in range(4):
			if shape[row][col] != 0:
				grid.set_cell(grid_position.x + col, 
							grid_position.y + row, tile_id)
	queue_free()
	emit_signal("killed")


func process_timer():
	position.y += cell_size
	# If the block can no longer move down:
	# revert the position change and kill it
	if not check_shape():
		position.y -= cell_size
		kill_block()


func set_timer_wait_time(time):
	timer.stop()
	timer.wait_time = time
	timer.start()
