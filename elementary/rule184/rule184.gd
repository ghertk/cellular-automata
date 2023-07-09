extends Node


@export var iterations: int = 32
@export var blank_cell_color: Color = Color.WHITE
@export var cell_color: Color = Color.BLACK
@export_range(0, 1, 0.01) var density: float = 0.25


func _ready() -> void:
	randomize()
	if not DirAccess.dir_exists_absolute("user://output-rule-184"):
		DirAccess.make_dir_absolute("user://output-rule-184")
	var dir = DirAccess.open("user://output-rule-184")

	var size = iterations
	var values: PackedByteArray = PackedByteArray()
	for cell in range(size):
		values.append(randf() > 1 - density)

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
				if center == 1 and right == 0:
					values.append(0)
				else:
					values.append(1)
			else:
				if center == right and right == 1:
					values.append(1)
				else:
					values.append(0)

	var image = Image.create(size, iterations, false, Image.FORMAT_RGBA8)
	image.fill(blank_cell_color)

	for i in range(values.size()):
		if values[i] == 1:
			var row: int = i / size
			var column: int = i % size
			image.set_pixel(column, row, cell_color)

	var file_path = dir.get_current_dir() + "/" + "rule184-{0}x{1}-density={2}.png".format([image.get_width(), image.get_height(), str(density * 100)])
	print("Saving image: " + file_path)
	image.save_png(file_path)
