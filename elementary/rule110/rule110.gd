extends Node


@export var iterations: int = 32
@export var blank_cell_color: Color = Color.WHITE
@export var cell_color: Color = Color.BLACK


func _ready() -> void:
	if not DirAccess.dir_exists_absolute("user://output-rule-110"):
		DirAccess.make_dir_absolute("user://output-rule-110")
	var dir = DirAccess.open("user://output-rule-110")

	var size = iterations
	var middle: int = size - 1
	var values: PackedByteArray = PackedByteArray()
	for cell in range(size):
		values.append(cell == middle)

	for r in range(iterations):
		for l in range(size):
			var cell_index = r * size + l
			var left = 0
			if cell_index != 0:
				left = values[cell_index - 1]
			var right = 0
			if cell_index % size != size - 1:
				right = values[cell_index + 1]
			var center = values[cell_index]

			if left == 1:
				if center == right:
					values.append(0)
				else:
					values.append(1)
			else:
				if center == right and right == 0:
					values.append(0)
				else:
					values.append(1)

	var image = Image.create(size, iterations, false, Image.FORMAT_RGBA8)
	image.fill(blank_cell_color)

	for i in range(values.size()):
		if values[i] == 1:
			var row: int = i / size
			var column: int = i % size
			image.set_pixel(column, row, cell_color)

	var file_path = dir.get_current_dir() + "/" + "rule110-{0}x{1}.png".format([image.get_width(), image.get_height()])
	print("Saving image: " + file_path)
	image.save_png(file_path)

