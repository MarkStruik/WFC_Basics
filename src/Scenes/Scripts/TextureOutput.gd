extends Node2D

export(Texture) var in_texture: Texture
onready var input_text := $Input
onready var tileset := $InputLocation/floorandwall
onready var outputSprite := $Output

func _init():
	randomize()
	# testing seed -> might be usefull to have specialize user enabled seed based generations
	seed("testing".hash())

	OS.center_window()

func _ready():
	
	var wfc = WaveFormCollapse.new(in_texture, 3, 50, 30)
	outputSprite.texture = wfc.generateOutputTexture()

	input_text.texture = in_texture
	draw_input_chunks(wfc)
	translate_image_to_tiles(in_texture.get_data())

func draw_input_chunks(wfc: WaveFormCollapse):
	var chunks = wfc.create_process_chunks()
	for chunk in chunks:
		var sprite = Sprite.new()
		var tex = ImageTexture.new()
		tex.lossy_quality = 0
		var img = Image.new()
		img.create(wfc._n,wfc._n,false,Image.FORMAT_RGBA8)
		
		img.lock()
		for x in wfc._n:
			for y in wfc._n:
				var pixel = chunk[1][x][y]
				var col := pixel as Color
				img.set_pixel(x, y, col)
		img.unlock()
		tex.create_from_image(img,0)
		sprite.texture = tex
		sprite.scale = Vector2(5,5)
		sprite.centered = false
		sprite.position = Vector2(70 + ( chunk[0].x * 20), -62.5 + ( chunk[0].y * 20 )) 
		add_child(sprite)

func translate_image_to_tiles(img: Image):
	
	#var tilesize = Vector2(16,16)
	
	# convert the global position into the tileset position
	var tilepos = Vector2.ZERO # tileset.world_to_map(start_pos + tilesize)
	img.lock()
	for x in img.get_width():
		for y in img.get_height():
			var curr_color = img.get_pixel(x, y)
			var current_tile = tilepos + Vector2(x,y)
			if curr_color.r8 == 255 and curr_color.g8 != 255:
				# set the tile
				#todo: add mapping for color to tile
				tileset.set_cell(current_tile.x, current_tile.y, 0)
			elif curr_color.r8 == 255 and curr_color.g8 == 255:
				tileset.set_cell(current_tile.x, current_tile.y, 1)


	img.unlock()
