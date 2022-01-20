extends Node2D

export(Texture) var in_texture: Texture
onready var input_text := $Input
onready var tileset := $floorandwall

func _init():
	OS.center_window()

func _ready():
	var wfc = WaveFormCollapse.new(in_texture)
	input_text.texture = in_texture
	draw_input_chunks(wfc)
		
	translate_image_to_tiles($TextureRect.rect_position, in_texture.get_data())

func draw_input_chunks(wfc: WaveFormCollapse):
	for chunk in wfc.processedChunks:
		var sprite = Sprite.new()
		var tex = ImageTexture.new()
		tex.lossy_quality = 0
		var img = Image.new()
		img.create(wfc._n,wfc._n,false,Image.FORMAT_RGBA8)
		
		img.lock()
		for x in wfc._n:
			for y in wfc._n:
				var pixel = chunk[1][x][y]
				
				var col := Color(pixel[0], pixel[1], pixel[2])
				img.set_pixel(x, y, col)
		img.unlock()
		tex.create_from_image(img,0)
		sprite.texture = tex
		sprite.scale = Vector2(5,5)
		sprite.centered = false
		sprite.position = Vector2(70 + ( chunk[0].x * 20), -62.5 + ( chunk[0].y * 20 )) 
		add_child(sprite)

func translate_image_to_tiles(start_pos: Vector2, img: Image):
	
	var tilesize = Vector2(16,16)
	
	# convert the global position into the tileset position
	var tilepos = tileset.world_to_map(start_pos + tilesize)
	img.lock()
	for x in img.get_width():
		for y in img.get_height():
			var curr_color = img.get_pixel(x, y)
			if curr_color.r8 != 0:
				# set the tile
				#todo: add mapping for color to tile
				var current_tile = tilepos + Vector2(x,y)
				tileset.set_cell(current_tile.x, current_tile.y, 0)
	img.unlock()
