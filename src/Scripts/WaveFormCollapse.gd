class_name WaveFormCollapse

var _n
var _outputWidth
var _outputHeight
var _inputTexture: Texture

func _init(input: Texture, n: int, width: int, height: int):
	_outputWidth = width
	_outputHeight = height
	_n = n;
	_inputTexture = input;
	
# ingest the texture into NxN pictures
# ex. when N = 3 this would result in:
# [codeblock] 
# [Vector2(0,0), [
# 	[ [Color],[Color],[Color] ], # rgb values for each pixel
# 	[ [Color],[Color],[Color] ], 
# 	[ [Color],[Color],[Color] ]
# ], etc
# [/codeblock] 
func create_process_chunks():
	var _processedChunks = []
	var height := _inputTexture.get_height() + 1
	var width := _inputTexture.get_width() + 1
	var image := _inputTexture.get_data()
	# needed to read the actual pictures
	image.lock()
	# only process if we have enough pixels for our 'N'
	if height >= _n and width >= _n:
		for y in (height - _n):
			for x in (width - _n):
				var block := _get_pixelData(image, Vector2(x,y))
				_processedChunks.append([Vector2(x,y),block])
	image.unlock() # unlock it so its available elsewhere again
	return _processedChunks

# Method to get an 'N' sector from a specific point on an image
# warning: image needs to be unlocked
func _get_pixelData(img: Image, start_pos: Vector2) -> Array:
	var res := []
	for x in _n:
		var row = []
		for y in _n:
			var cur_coord = start_pos + Vector2(x,y)
			var color = img.get_pixel(cur_coord.x, cur_coord.y)
			row.append(color)
		res.append(row)
			
	return res

# Generate Output Texture
func generateOutputTexture() -> Texture:
	# always start from scratch
	var chunks = create_process_chunks()

	# genrate array of pixels for the with and height
	var wave = _create_empty_wave_data(chunks)

	# pick a random starting chunk
	var rand_chunk_idx = int(rand_range(0,chunks.size()))
	var rand_chunk = chunks[rand_chunk_idx]

	# pick a random point on the map to 'place' a starting chunk
	# (optional) add more starting chunks for beter randomisations?
	var rand_x = int(rand_range(0, _outputWidth - _n))
	var rand_y = int(rand_range(0, _outputHeight - _n))
	var rand_pos = Vector2(rand_x, rand_y)
	
	# add random chunk to the texture
	for x in _n:
		for y in _n:
			var curr_pixel_rnd_chunk = Vector2(x,y) + rand_pos
			var wavePixel = wave[curr_pixel_rnd_chunk.x][curr_pixel_rnd_chunk.y]
			if curr_pixel_rnd_chunk == rand_pos: # this is the rnd pos
				wavePixel[1] = true
				wavePixel[2] = [rand_chunk] # this has been collapsed
			wavePixel[0] = rand_chunk[1][x][y]

	# while all pixels have not been processed repeat steps until done 
	# when we have tried 'x' times we stop the process if none of the items are moving forward
	# calculate wave from this random point outwards

	# todo radial wave
	var wave_points = _get_wave_points(1,rand_pos)

	for p in wave_points:
		var wavePixel = wave[p.x][p.y]
		wavePixel[0] = Color.green
		var pointsToCheck = _get_wave_points(1,Vector2(p.x,p.y))
		
	
	# check which chunks fit on the current pixel ( any pixel matching in the NxN )
	# take the entire NxN with surrounding pixels in mind when trying to match

		# if there is only one options thats the one, mark the item as complete

		# else remove the ones you don't need

		
	var tex = _create_texture_from(wave)
	return tex

func _get_wave_points(wave_nr, start_pos):
	var result = []

	# get corners 
	var top_left = start_pos + ( Vector2(-1,-1) * wave_nr )
	var top_right = start_pos + ( Vector2(1,-1) * wave_nr )
	var bottom_left = start_pos + ( Vector2(-1,1) * wave_nr )
	var bottom_right = start_pos + ( Vector2(1,1) * wave_nr )

	# floodfill between topleft to bottom right
	
	# alternate between 
	# points between tl -> tr
	var tltr = [] 
	for x in range(top_left.x, top_right.x + 1):
		var y = top_left.y
		if  y < 0 and y >= _outputHeight:
			break
		elif x >= 0 and x < _outputWidth:
			tltr.append(Vector2(x, y))
	# points between tl -> bl
	var tlbl = []
	for y in range(top_left.y, bottom_left.y + 1):
		var x = top_left.x
		if x < 0 and x >= _outputWidth:
			break;
		elif y >= 0 and y < _outputHeight:
			tlbl.append(Vector2(x, y))

	# alternate between
	# points between bl -> br
	var blbr = [] 
	for x in range(bottom_left.x, bottom_right.x + 1):
		var y = bottom_left.y
		if  y < 0 and y >= _outputHeight:
			break
		elif  x >= 0 and x < _outputWidth:
			blbr.append(Vector2(x, y))
	# points between tr -> br
	var trbr = []
	for y in range(top_right.y, bottom_right.y + 1):
		var x = top_right.x
		if x < 0 and x >= _outputWidth:
			break;
		elif y >= 0 and y < _outputHeight:
			trbr.append(Vector2(x, y))

	result.append_array(tltr)
	result.append_array(tlbl)
	result.append_array(blbr)
	result.append_array(trbr)
	
	return result

# returns full array of wave texture
# each pixel contains => 
# 0: color, 
# 1: boolean if fully checked = false, 
# 2: all available chunks -> todo optimise later?!
func _create_empty_wave_data(chunks) -> Array:
	var wave := []
	for	x in _outputWidth:
		var row = []
		for y in _outputHeight:
			# transparent is used as empty color here
			row.append([Color.transparent, false, chunks.duplicate(true)])
		wave.append(row)
	return wave

func _create_texture_from(waveData: Array) -> Texture:
	var tex = ImageTexture.new()
	tex.lossy_quality = 0
	var img = Image.new()
	img.create(_outputWidth,_outputHeight,false,Image.FORMAT_RGBA8)
	img.lock()

	for	x in _outputWidth:
		for y in _outputHeight:
			img.set_pixel(x,y,waveData[x][y][0]) 

	img.unlock()
	tex.create_from_image(img,0)
	return tex
