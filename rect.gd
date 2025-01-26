extends ColorRect

# TODO
# dead cells
# generations count before infinit cycle
# vessel grab and release
# save with seed or init array / size
# rule and kernel
# display grid on grab and release
# Icons (settins / pause / play)

const DEBUG = true
const CELL_SIZE = 10  # Pixel size for each cell
const CELL_MARGIN = 2

# toolbar counts
var iteration_count = 0
var alive_cells_at_start_count = 0
var iteration_count_label: Label
var start_cells_count_label: Label
var cell_counts_container: HBoxContainer
var cell_counts_container_size: Vector2
var cell_counts_graph
var full_screen_layer
var full_screen = false
var cells_count = 0

var timer = Timer
var is_paused = false
var update_interval = 0.1
var time_accumulator = 0.0
var last_toggled = Vector2(-1, -1)
var is_dragging = false

var grid_size_x: int
var grid_size_y: int
var grid: Array = []
var new_gen: Array = []
var changed_cells: Array = []
var neighbor_counts: Array = []

func _ready():
	iteration_count_label = get_parent().get_node("Control/MarginContainer/VBoxContainer/GenerationsCount")
	start_cells_count_label = get_parent().get_node("Control/MarginContainer/VBoxContainer/StartCellsCount")
	cell_counts_graph = get_parent().get_node("Control/MarginContainer/VBoxContainer/HBoxContainer/CellCountsGraph")
	update_iteration_display()
	call_deferred("compute_grid_size")

func update_iteration_display():
	iteration_count_label.text = "Generations: " + str(iteration_count)

func update_cells_at_start_count():
	start_cells_count_label.text = "Starting cells: " + str(alive_cells_at_start_count)

func compute_grid_size():
	grid_size_x = int(get_size().x / CELL_SIZE)
	grid_size_y = int(get_size().y / CELL_SIZE)
	if DEBUG: print("grid_size_x: ", grid_size_x)
	if DEBUG: print("grid_size_y: ", grid_size_y)
	randomize()
	initialize_grids()
	queue_redraw()
	full_screen_layer = $"../../FullScreenLayer"
	cell_counts_container = get_parent().get_node("Control/MarginContainer/VBoxContainer/HBoxContainer")
	cell_counts_container_size = cell_counts_container.size
	cell_counts_graph.init((grid_size_x * grid_size_y) / 2, 40, full_screen_layer)
	cell_counts_graph.full_screen_toggled.connect(Callable(self,"_on_full_screen_toggled"))


func initialize_grids():
	for x in range(grid_size_x):
		grid.append([])
		new_gen.append([])
		neighbor_counts.append([])
		for y in range(grid_size_y):
			grid[x].append(int(randf() < 0.5))                                  # Randomly alive (1) or dead (0) with ~50% alive cells
			new_gen[x].append(0)
			neighbor_counts[x].append(0)

	for x in range(grid_size_x):
		for y in range(grid_size_y):
			if grid[x][y] == 1:
				alive_cells_at_start_count += 1
				update_neighbor_counts(x, y, 1)
	update_cells_at_start_count()
	cells_count = alive_cells_at_start_count

func _process(delta):
	if is_paused:
		return

	time_accumulator += delta
	if time_accumulator >= update_interval:
		time_accumulator -= update_interval # resets the accumulator by the interval
		update_grid()
		iteration_count += 1
		update_iteration_display()
		cell_counts_graph.add_data_value(cells_count)
		queue_redraw()

func _draw():
	for x in range(grid_size_x):
		for y in range(grid_size_y):
			var cell_color = ThemeColors.ALIVE_CELL if grid[x][y] == 1 else ThemeColors.DEAD_CELL
			var rect_x = (x * CELL_SIZE) + CELL_MARGIN
			var rect_y = (y * CELL_SIZE) + CELL_MARGIN
			var width = CELL_SIZE - CELL_MARGIN
			var height = CELL_SIZE - CELL_MARGIN
			draw_rect(Rect2(rect_x, rect_y, width, height), cell_color)

func _input(event):
	if full_screen: # ignores input when a graph is currently full_screen
		return
	if event is InputEventMouseButton:
		var mouse_pos = get_local_mouse_position()
		var cell_x = int(mouse_pos.x / CELL_SIZE)
		var cell_y = int(mouse_pos.y / CELL_SIZE)
		var cell_pos = Vector2(cell_x, cell_y)

		if not in_grid(cell_x, cell_y):
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			pause()
			print("here")
			if event.pressed:
				is_dragging = false
				last_toggled = cell_pos
			else:
				# on release, check if we'r currently draggin or just clicking
				if not is_dragging:
					toggle_cell(cell_x, cell_y)
					is_dragging = false
					last_toggled = Vector2(-1, -1)
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var mouse_pos = get_local_mouse_position()
		var cell_x = int(mouse_pos.x / CELL_SIZE)
		var cell_y = int(mouse_pos.y / CELL_SIZE)
		var cell_pos = Vector2(cell_x, cell_y)
		if in_grid(cell_x, cell_y) and cell_pos != last_toggled:
			pause()
			grid[cell_x][cell_y] = 1
			update_neighbor_counts(cell_x, cell_y, 1)
			alive_cells_at_start_count += 1
			cells_count += 1
			last_toggled = cell_pos
			is_dragging = true
			update_cells_at_start_count()
			queue_redraw()

func toggle_cell(x, y):
	var new_state = 1 if grid[x][y] == 0 else 0
	grid[x][y] = new_state
	update_neighbor_counts(x, y, new_state)
	alive_cells_at_start_count += 1 if new_state == 1 else -1
	cells_count += 1 if new_state == 1 else -1 # can break count if cell already alive ?
	update_cells_at_start_count()
	queue_redraw()

func update_grid():
	changed_cells.clear()

	for x in range(grid_size_x):
		for y in range(grid_size_y):
			var live_neighbors = neighbor_counts[x][y]
			var cell = grid[x][y]

			# Conway's rules
			if cell == 1 and not (live_neighbors == 2 or live_neighbors == 3):
				new_gen[x][y] = 0    # cell dies
				changed_cells.append(Vector2(x, y))
				cells_count -= 1
			elif cell == 0 and live_neighbors == 3:
				new_gen[x][y] = 1    # cell becomes alive
				changed_cells.append(Vector2(x, y))
				cells_count += 1
			else:
				new_gen[x][y] = cell # cell remains dead

	for pos in changed_cells:
		var x = pos.x
		var y = pos.y
		update_neighbor_counts(x, y, new_gen[x][y])

	var tmp = grid
	grid = new_gen
	new_gen = tmp

func update_neighbor_counts(x: int, y: int, new_state: int):
	var delta = 1 if new_state == 1 else -1
	
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = (x + dx) % grid_size_x
			var ny = (y + dy) % grid_size_y
			#if in_grid(nx, ny):
			neighbor_counts[nx][ny] += delta

func in_grid(x, y):
	if x >= 0 and x < grid_size_x and y >= 0 and y < grid_size_y:
		return true
	return false

#func format_large_number(value):
	#if value >= 1_000_000:
		#return "%0.1fM" % (value / 1_000_000)
	#elif value >= 1_000:
		#return "%0.1fk" % (value / 1_000)
	#else:
		#return str(value)

func reset_grid():
	for x in range(grid_size_x):
		for y in range(grid_size_y):
			grid[x][y] = 0
			neighbor_counts[x][y] = 0
	iteration_count = 0
	alive_cells_at_start_count = 0
	cells_count = 0
	update_iteration_display()
	update_cells_at_start_count()
	queue_redraw()

func random_fill():
	alive_cells_at_start_count = 0
	cells_count = 0

	for x in range(grid_size_x):
		for y in range(grid_size_y):
			var cell_state = int(randf() < 0.5)
			grid[x][y] = cell_state
			neighbor_counts[x][y] = 0
			if cell_state == 1:
				alive_cells_at_start_count += 1
				cells_count += 1
	for x in range(grid_size_x):
		for y in range(grid_size_y):
			if grid[x][y] == 1:
				update_neighbor_counts(x, y, 1)
	iteration_count = 0
	update_iteration_display()
	update_cells_at_start_count()
	queue_redraw()

func pause():
	get_parent().get_node("Control/MarginContainer/VBoxContainer/PauseButton").text = "Play"
	is_paused = true

func play():
	get_parent().get_node("Control/MarginContainer/VBoxContainer/PauseButton").text = "Pause"
	is_paused = false

func toggle_pause():
	if is_paused:
		play()
	else:
		pause()

func _on_reset_button_pressed():
	pause()
	reset_grid()

func _on_random_button_pressed():
	_on_reset_button_pressed()
	random_fill()

func _on_pause_button_pressed():
	toggle_pause()

func _on_full_screen_toggled():
	full_screen = not full_screen
	#print("sig received:", full_screen)
