extends "res://Blocks/Block.gd"

func _ready():
	bounds = [[1, 3], [1, 3], [1, 3], [1, 3]]
	shapes = [[ [0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0], 
				[0, 0, 0, 0]],
				
			[	[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0]], 
				
			[	[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0]], 
				
			[	[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0]]
			]
	tile_id = 0
	change_shape(0)
	$Timer.wait_time = 1
	$Timer.start()


func _on_Timer_timeout():
	position.y += cell_size
	if not check_shape():
		position.y -= cell_size
