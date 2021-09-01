extends TileMap

export (int) var grid_width = 10
export (int) var grid_heigth = 20

signal score_change(new_score)
signal level_change(new_level)
signal next_change(next)
signal hold_change(hold)
signal new_game

var speed

enum {ORANGE_CELL, CYAN_CELL, RED_CELL, BLUE_CELL, PURPLE_CELL, 
		GREEN_CELL, YELLOW_CELL, GREY_CELL}

var blocks = []
var active_block : Node2D
var active_block_id

var score = 0
var total_lines_cleared = 0
var level : int = 0
var levels = [0.72, 0.64, 0.58, 0.5, 0.44, 0.36, 0.3, 0.22, 0.14, 0.1, 0.08, 
			0.08, 0.08, 0.06, 0.06, 0.06, 0.04, 0.04, 0.04, 0.02]

var next_block

enum {PLAYING, GAME_OVER}
var state

var holded_block_id
var can_hold

func _ready():
	randomize()
	blocks.append(load("res://blocks/IBlock.tscn"))
	blocks.append(load("res://blocks/TBlock.tscn"))
	blocks.append(load("res://blocks/LBlock.tscn"))
	blocks.append(load("res://blocks/JBlock.tscn"))
	blocks.append(load("res://blocks/SBlock.tscn"))
	blocks.append(load("res://blocks/ZBlock.tscn"))
	blocks.append(load("res://blocks/OBlock.tscn"))


func _process(_delta):
	if Input.is_action_just_pressed("hold") and can_hold:
		var block_id = holded_block_id
		holded_block_id = active_block_id
		active_block.queue_free()
		yield(get_tree(), "idle_frame")
		create_new_block(block_id)
		can_hold = false
		emit_signal("hold_change", holded_block_id)


func create_new_block(block_id = -1):
	if state == PLAYING:
		if block_id == -1:
			active_block_id = next_block
			random_next_block()
		else:
			active_block_id = block_id
		active_block = blocks[active_block_id].instance()
		active_block.grid_path = self.get_path()
		active_block.position = Vector2(64 * 3, 64 * -1)
		add_child(active_block)
		can_hold = true
		
		# check if a block is already at that position = game over
		if not active_block.check_shape():
			yield(game_over(), "completed")
			return
		active_block.normal_speed = speed
		active_block.set_timer_wait_time(speed)
		active_block.connect("killed", self, "block_killed")
		active_block.connect("soft_drop", self, "soft_drop_score")
		active_block.connect("hard_drop", self, "hard_drop_score")


func game_over():
	state = GAME_OVER
	active_block.queue_free()
	for row in range(grid_heigth - 1, -1, -1):
		for col in range(grid_width):
			set_cell(col, row, GREY_CELL)
		yield(get_tree().create_timer(0.01), "timeout")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	for row in range(grid_heigth - 1, -1, -1):
		for col in range(grid_width):
			set_cell(col, row, -1)
		yield(get_tree().create_timer(0.01), "timeout")
	emit_signal("new_game")


func start_new_game():
	for row in range(grid_heigth - 1, -1, -1):
		for col in range(grid_width):
			set_cell(col, row, -1)
	score = 0
	emit_signal("score_change", score)
	level = 0
	emit_signal("level_change", level)
	total_lines_cleared = 0
	random_next_block()
	holded_block_id = -1
	state = PLAYING
	speed = levels[level]
	emit_signal("new_game")
	create_new_block()


func random_next_block():
	next_block = randi() % blocks.size()
	emit_signal("next_change", next_block)


func block_killed():
	yield(update_grid(), "completed")
	create_new_block()


func clear_row(row):
	# play animation on row
	for col in range(grid_width):
		set_cell(col, row, -1)
		yield(get_tree().create_timer(0.02), "timeout")
	
	# drop all the rows above it
	for r in range(row, 0, -1):
		for col in range(grid_width):
			set_cell(col, r, get_cell(col, r-1))
	
	# Update the score
	update_score(1)


func update_score(increment : int):
	score += increment
	emit_signal("score_change", score)


func update_grid():
	# used to emit any signal so yield can be used
	yield(get_tree(), "idle_frame")
	
	var cleared_rows = []
	for row in range(grid_heigth):
		var cleared = true
		for col in range(grid_width):
			if get_cell(col, row) == INVALID_CELL:
				cleared = false
		if cleared:
			cleared_rows.append(row)
	
	if not cleared_rows.empty():
		var nb_rows = cleared_rows.size()
		for row in range(nb_rows - 1):
			clear_row(cleared_rows[row])
		yield(clear_row(cleared_rows[nb_rows - 1]), "completed")

		var base_inc = 800
		if nb_rows == 1:
			base_inc = 100
		elif nb_rows == 2:
			base_inc = 300
		elif nb_rows == 3:
			base_inc = 500
		update_score(level * base_inc)

		total_lines_cleared += nb_rows
		var new_level = clamp(total_lines_cleared / 10, 0, 19)
		if new_level != level:
			level = new_level
			speed = levels[level]
			emit_signal("level_change", level)


func soft_drop_score():
	update_score(1)


func hard_drop_score(nb_cells):
	update_score(2 * nb_cells)
