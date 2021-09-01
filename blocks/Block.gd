extends Node2D


const drop_speed = 0.01
const final_delay = 0.5

export (int) var grid_width = 10
export (int) var grid_heigth = 20
export (int) var cell_size = 64
export (NodePath) var grid_path

var bounds
var shapes
var tile_id
signal killed
signal soft_drop
signal hard_drop(nb_cells)

var grid : TileMap
var timer : Timer # used for moving the block down the grid
var final_timer : Timer

var move_counter
export var move_cooldown = 0.07

enum {MOVING, STOPPED}

var blocks = [["Block1", "Block2", "Block3", "Block4"],
				["Block5", "Block6", "Block7", "Block8"],
				["Block9", "Block10", "Block11", "Block12"],
				["Block13", "Block14", "Block15", "Block16"]]

var current_shape = 0

var normal_speed
var is_soft_dropping

func _ready():
	grid = get_node(grid_path)
	
	timer = Timer.new()
	timer.one_shot = false
	timer.connect("timeout", self, "process_timer")
	add_child(timer)
	
	final_timer = Timer.new()
	final_timer.wait_time = final_delay
	final_timer.one_shot = true
	final_timer.connect("timeout", self, "kill_block")
	add_child(final_timer)
	
	move_counter = 0


func _process(delta):
	# Rotate
	if Input.is_action_just_pressed("rotate"):
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
				clam_position_x()
		
	# Soft drop
	if Input.is_action_just_pressed("soft_drop"):
		set_timer_wait_time(drop_speed)
		is_soft_dropping = true
	if Input.is_action_just_released("soft_drop"):
		set_timer_wait_time(normal_speed)
		is_soft_dropping = false

	# Hard drop
	if Input.is_action_just_pressed("hard_drop"):
		var nb_cells = 0
		while check_shape():
			nb_cells += 1
			position.y += cell_size
		position.y -= cell_size
		nb_cells -= 1
		emit_signal("hard_drop", nb_cells)


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
		clam_position_x()


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
	position.y += cell_size
	var can_still_move = check_shape()
	position.y -= cell_size

	if can_still_move:
		return

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
	# revert the position change and start final timer if not already started
	if not check_shape():
		position.y -= cell_size
		if final_timer.is_stopped():
			final_timer.start()
	else:
		if not final_timer.is_stopped():
			final_timer.stop()
		if is_soft_dropping:
			emit_signal("soft_drop")


func set_timer_wait_time(time):
	timer.stop()
	timer.wait_time = time
	timer.start()


func clam_position_x():
	position.x = clamp(position.x, 
								bounds[current_shape][0] * cell_size, 
								(grid_width * cell_size) - (bounds[current_shape][1] * cell_size))
