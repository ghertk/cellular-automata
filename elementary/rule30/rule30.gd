extends Node


@export_range(1, 32, 1) var iterations: int = 32
@export var blank_cell_color: Color = Color.WHITE
@export var cell_color: Color = Color.BLACK


func _ready() -> void:
	if not DirAccess.dir_exists_absolute("user://output-rule-30"):
		DirAccess.make_dir_absolute("user://output-rule-30")
	var dir = DirAccess.open("user://output-rule-30")

	var size = iterations * 2 - 1
	var state = 1 << iterations - 1

	var image = Image.create(size, iterations, false, Image.FORMAT_RGBA8)
	image.fill(blank_cell_color)
	var result = PackedInt64Array()

	for i in range(iterations):
		result.append(state)
		state = (state >> 1) ^ (state | state << 1)

	for row in range(result.size()):
		var value = result[row]
		for column in range(size):
			if value >> column & 1:
				image.set_pixel(size - 1 - column, row, cell_color)

	var file_path = dir.get_current_dir() + "/" + "rule30-{0}x{1}.png".format([image.get_width(), image.get_height()])
	print("Saving image: " + file_path)
	image.save_png(file_path)

