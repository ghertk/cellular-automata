extends Control


@export_range(1, 255) var cell_size: int = 25 ## Cell size in pixels
@export var iteration_delay_msec: int = 2000 ## iteration delay in miniseconds

@export_range(0, 1, 0.01) var noise_density: float = 0.5


var running: bool = false
var current_grid = []
var grid_size: Vector2i

var next_iteration_time: int = 0
var iteration_number: int = 0
var calculating_next_iteration: bool = false


func _ready() -> void:
	randomize()
	var viewport = get_viewport()
	viewport.size_changed.connect(on_resize)
	grid_size = viewport.size / cell_size
	reset_grid()


func _physics_process(_delta: float) -> void:
	if running and Time.get_ticks_msec() > next_iteration_time:
		if not calculating_next_iteration:
			process_next_iteration()


func _draw() -> void:
	for r in range(grid_size.x):
		for c in range(grid_size.y):
			var v = get_cell(r, c)
			var color = Color.BLACK if v else Color.WHITE
			draw_rect(Rect2(r * cell_size, c * cell_size, cell_size, cell_size), color)
			queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_P and event.pressed:
			running = not running
		elif not running and event.keycode == KEY_N and event.pressed:
			generate_noise()
			iteration_number = 0
			queue_redraw()
	elif not running and event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				var r = floori(event.position.x / cell_size)
				var c = floori(event.position.y / cell_size)
				toggle_cell(r, c)
				queue_redraw()
			elif event.button_index == 2:
				var r = floori(event.position.x / cell_size)
				var c = floori(event.position.y / cell_size)
				print(count_neighbor(r, c))


func process_next_iteration() -> void:
	calculating_next_iteration = true
	iteration_number += 1
	print("Iteration: ", iteration_number)
	var next_grid = current_grid.duplicate()
	for r in range(grid_size.x):
		for c in range(grid_size.y):
			var v = get_cell(r, c)
			var neighbors = count_neighbor(r, c)
			if neighbors < 2 or neighbors > 3:
				next_grid[get_cell_index(r, c)] = false
			if not v and neighbors == 3:
				next_grid[get_cell_index(r, c)] = true
	current_grid = next_grid
	next_iteration_time = Time.get_ticks_msec() + iteration_delay_msec
	queue_redraw()
	calculating_next_iteration = false



func reset_grid() -> void:
	current_grid.resize(grid_size.x * grid_size.y)
	for r in range(grid_size.x):
		for c in range(grid_size.y):
			set_cell(r, c, false)


func get_cell(r: int, c: int) -> bool:
	if r < 0 or r >= grid_size.x or c < 0 or c >= grid_size.y:
		return false
	return current_grid[r * grid_size.y + c]


func get_cell_index(r: int, c: int) -> int:
	if r < 0 or r >= grid_size.x or c < 0 or c >= grid_size.y:
		return -1
	return r * grid_size.y + c


func set_cell(r: int, c: int, v: bool) -> void:
	if r < 0 or r >= grid_size.x:
		return
	if c < 0 or c >= grid_size.y:
		return
	current_grid[r * grid_size.y + c] = v


func toggle_cell(r: int, c: int) -> void:
	if r < 0 or r >= grid_size.x:
		return
	if c < 0 or c >= grid_size.y:
		return
	current_grid[r * grid_size.y + c] = not current_grid[r * grid_size.y + c]


func count_neighbor(r, c) -> int:
	var neighbor_cells = 0
	if get_cell(r - 1, c - 1):
		neighbor_cells += 1
	if get_cell(r - 1, c):
		neighbor_cells += 1
	if get_cell(r - 1, c + 1):
		neighbor_cells += 1
	if get_cell(r, c - 1):
		neighbor_cells += 1
	if get_cell(r, c + 1):
		neighbor_cells += 1
	if get_cell(r + 1, c - 1):
		neighbor_cells += 1
	if get_cell(r + 1, c):
		neighbor_cells += 1
	if get_cell(r + 1, c + 1):
		neighbor_cells += 1
	return neighbor_cells


func generate_noise() -> void:
	for r in range(grid_size.x):
		for c in range(grid_size.y):
			set_cell(r, c, randf() < noise_density)


func on_resize() -> void:
	if not running:
		grid_size = get_viewport().size / cell_size
		reset_grid()

