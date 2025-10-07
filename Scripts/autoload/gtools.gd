extends Node



func resize_texture(texture: Texture2D, size: int) -> ImageTexture:
	var img = texture.get_image()
	img.resize(size, size, Image.INTERPOLATE_NEAREST)
	var new_tex = ImageTexture.create_from_image(img)
	return new_tex



func make_square_texture(texture: Texture2D) -> ImageTexture:
	# Get image data from texture
	var img := texture.get_image()

	# Determine square size (longest side)
	var max_side : int = max(img.get_width(), img.get_height())

	# Create a new square image with white background
	var square := Image.create(max_side, max_side, false, Image.FORMAT_RGBA8)
	square.fill(Color(1, 1, 1, 1))

	# Compute offset so original image is centered
	var x_off := int((max_side - img.get_width()) / 2)
	var y_off := int((max_side - img.get_height()) / 2)

	# Blit (copy) the original image into the square one
	square.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(x_off, y_off))

	# Convert to texture and return
	return ImageTexture.create_from_image(square)
