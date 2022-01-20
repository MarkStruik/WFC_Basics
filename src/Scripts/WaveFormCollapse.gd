extends Object
class_name WaveFormCollapse

var _n = 3;

var processedChunks = []

func _init(input: Texture):
	create_process_chunks(input)

func create_process_chunks(input: Texture):
	# ingest the texture into NxN pictures
	var height := input.get_height() + 1
	var width := input.get_width() + 1
	var textureData := input.get_data() # get pixels from sample
	textureData.lock()
	if height > _n and width > _n:
		# get horizontal data
		for y in (height - _n):
			for x in (width - _n):
				var block := get_pixelData(textureData, Vector2(x,y))
				processedChunks.append([Vector2(x,y),block])

func get_pixelData(img: Image, start_pos: Vector2) -> Array:
	var res := []
	for x in _n:
		var row = []
		for y in _n:
			var cur_coord = start_pos + Vector2(x,y)
			var color = img.get_pixel(cur_coord.x, cur_coord.y)
			row.append([color.r8, color.g8, color.b8])
		res.append(row)
			
	return res
