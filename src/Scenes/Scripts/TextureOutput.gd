extends Node2D

export(Texture) var in_texture: Texture
onready var input_text := $Input

func _init():
	OS.center_window()

func _ready():
	var wfc = WaveFormCollapse.new(in_texture)
	input_text.texture = in_texture
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
	
