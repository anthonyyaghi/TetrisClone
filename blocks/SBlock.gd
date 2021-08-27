extends "res://blocks/Block.gd"

func _ready():
	bounds = [[0, 3], [0, 2], [0, 3], [0, 2]]
	shapes = [[ [0, 0, 0, 0],
				[0, 1, 1, 0],
				[1, 1, 0, 0],
				[0, 0, 0, 0]],
				
			[	[1, 0, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0]], 
				
			[	[0, 0, 0, 0],
				[0, 1, 1, 0],
				[1, 1, 0, 0],
				[0, 0, 0, 0]], 
				
			[	[1, 0, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0]]
			]
	tile_id = 4
	change_shape(0)
