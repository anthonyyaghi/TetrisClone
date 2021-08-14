extends TileMap

export (int) var grid_width = 10
export (int) var grid_heigth = 20

var speed

var blocks = []
var active_block : Node2D

signal cleared_row(row)

func _ready():
	randomize()
	speed = 1
	blocks.append(load("res://Blocks/LBlock.tscn"))
	blocks.append(load("res://Blocks/JBlock.tscn"))
	blocks.append(load("res://Blocks/IBlock.tscn"))
	blocks.append(load("res://Blocks/TBlock.tscn"))
	blocks.append(load("res://Blocks/SBlock.tscn"))
	blocks.append(load("res://Blocks/ZBlock.tscn"))
	blocks.append(load("res://Blocks/OBlock.tscn"))
	create_new_block()
	$Timer.start()


func create_new_block():
	active_block = blocks[randi() % blocks.size()].instance()
	active_block.grid_path = self.get_path()
	add_child(active_block)
	active_block.position = Vector2(64 * 5, 0)
	active_block.set_timer_wait_time(speed)
	active_block.connect("killed", self, "block_killed")


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
		for row in range(cleared_rows.size() - 1):
			clear_row(cleared_rows[row])
		yield(clear_row(cleared_rows[cleared_rows.size() - 1]), "completed")


func _on_Timer_timeout():
	speed = speed / 1.5
