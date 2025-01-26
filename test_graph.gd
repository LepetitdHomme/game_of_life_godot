extends Control

signal full_screen_toggled

var line: Line2D
var label: Label
var container: BoxContainer
var container_size: Vector2
var container_position: Vector2
var data_values = []
# fullscreen utilities
var is_fullscreen = false
var parent: Node
var index: int
# params
var max_y_requested
var display_count_requested
var full_screen_layer: CanvasLayer

func _ready():
	line = $BoxContainer/Line2D
	container = $BoxContainer
	container_size = container.size
	container_position = container.position
	label = $BoxContainer/Label
	parent = get_parent()
	index = get_index()
	line.width = 2
	line.default_color = Color(1, 0, 0)

func init(max_y, display_count, fsl):
	max_y_requested = max_y
	display_count_requested = display_count
	full_screen_layer = fsl

func add_data_value(new_data_value):
	data_values.append(new_data_value)
	label.text = "Alive cells: " + str(new_data_value)
	display_graph()

func display_graph():
	var values

	if is_fullscreen or data_values.size() < display_count_requested:
		values = data_values
	else:
		values = data_values.slice(-display_count_requested, -1)
	var width = container.size.x
	var height = container.size.y
	var x_spacing = width / float(values.size() - 1)
	var points = []

	for i in range(values.size()):
		var value = values[i]
		var x = i * x_spacing
		var y = height - ((height * value) / max_y_requested)
		points.append(Vector2(x, y))
	line.points = points

func _on_button_pressed() -> void:
	if is_fullscreen:
		reverse_full_screen()
	else:
		go_full_screen()
	emit_signal("full_screen_toggled")
	display_graph()
	is_fullscreen = not is_fullscreen

func reverse_full_screen():
	line.points = []
	get_parent().remove_child(self)
	parent.add_child(self)
	parent.move_child(self, index)
	parent.show()
	set_size(container_size)
	set_position(container_position)
	full_screen_layer.hide()

func go_full_screen():
	line.points = []
	container_size = container.size
	container_position = container.position
	parent.hide()
	parent.remove_child(self)
	full_screen_layer.add_child(self)
	full_screen_layer.show()
	set_size(get_viewport_rect().size)
	set_position(Vector2.ZERO)
