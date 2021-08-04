extends Node2D

export (int) var grid_width = 10
export (int) var grid_heigth = 10
export (int) var cell_size = 64
export (NodePath) var grid_path

var grid : TileMap

var blocks = [["Block1", "Block2", "Block3", "Block4"],
				["Block5", "Block6", "Block7", "Block8"],
				["Block9", "Block10", "Block11", "Block12"],
				["Block13", "Block14", "Block15", "Block16"]]

var shapes = [[ [0, 0, 0, 0],
				[1, 1, 1, 0],
				[1, 0, 0, 0],
				[0, 0, 0, 0]],
				
			[	[1, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0]], 
				
			[	[0, 0, 0, 0],
				[0, 0, 1, 0],
				[1, 1, 1, 0],
				[0, 0, 0, 0]], 
				
			[	[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0]]
			]

var current_shape = 0

func _ready():
	change_shape(0)
	$Timer.wait_time = 1
	$Timer.start()
	grid = get_node(grid_path)


func _process(delta):
	var rot_dir = 0
	if Input.is_action_just_pressed("rotate_left"):
		rot_dir += 1
	elif Input.is_action_just_pressed("rotate_right"):
		rot_dir -= 1
	if rot_dir == 1:
		next_shape()
	elif rot_dir == -1:
		prev_shape()
	
	var move_dir = 0
	if Input.is_action_just_pressed("ui_left"):
		move_dir -= 1
	elif Input.is_action_just_pressed("ui_right"):
		move_dir += 1
	if move_dir == 1:
		position.x += 65
	elif move_dir == -1:
		position.x -= 65
	position.x = clamp(position.x, grid.position.x, 
						grid.position.x + (grid_width * cell_size))


func next_shape():
	var shape = (current_shape - 1) % 4
	change_shape(shape)


func prev_shape():
	var shape = (current_shape + 1) % 4
	change_shape(shape)


func change_shape(shape):
	current_shape = shape
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
	print(grid_position)
	var shape = shapes[current_shape]
	
	for row in range(4):
		for col in range(4):
			if (shape[row][col] != 0 and 
				(grid.get_cell(col + grid_position.x, row + grid_position.y) != TileMap.INVALID_CELL or 
				row + grid_position.y >= grid_heigth)):
				return false
	return true


func _on_Timer_timeout():
	position.y += cell_size
	if not check_shape():
		position.y -= cell_size
