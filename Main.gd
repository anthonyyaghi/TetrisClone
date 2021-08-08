extends TileMap

export (int) var grid_width = 10
export (int) var grid_heigth = 20

var blocks = []
var active_Block : Node2D

signal cleared_row(row)

func _ready():
	randomize()
	blocks.append(load("res://LBlock.tscn"))
	blocks.append(load("res://JBlock.tscn"))
	create_new_block()


func create_new_block():
	active_Block = blocks[randi()%2].instance()
	active_Block.grid_path = self.get_path()
	add_child(active_Block)
	active_Block.position = Vector2(64*5, 0)
	active_Block.connect("killed", self, "block_killed")


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
