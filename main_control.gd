extends Control

var themes = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_themes()
	apply_theme_colors()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_settings_button_pressed():
	get_node("HSplitContainer/ColorRect").pause()
	$SettingsPopup.popup_centered()

func _on_close_button_pressed():
	$HSplitContainer/Control/MarginContainer/VBoxContainer/SettingsButton.release_focus()
	$SettingsPopup.hide()
	#get_node("HSplitContainer/ColorRect").is_paused = false

func _on_theme_option_button_item_selected(index):
	var theme_option_button = $SettingsPopup/VBoxContainer/HBoxContainer/OptionButton
	var theme_name = theme_option_button.get_item_text(index)
	
	if theme_name in themes:
		for color_name in themes[theme_name]:
			var color_values = themes[theme_name][color_name]
			var color = Color8(int(color_values[0]), int(color_values[1]), int(color_values[2]))
			ThemeColors.set(color_name, color)

		# Trigger a redraw of the grid to apply the new colors
		apply_theme_colors()
		queue_redraw()

func apply_theme_colors():
	$HSplitContainer/ColorRect.color = ThemeColors.GAME_BG
	$HSplitContainer/Control/ColorRect.color = ThemeColors.TOOLS_BG
	$HSplitContainer/Control/MarginContainer/VBoxContainer/StartCellsCount.modulate = ThemeColors.TOOLS_TEXT
	$HSplitContainer/Control/MarginContainer/VBoxContainer/GenerationsCount.modulate = ThemeColors.TOOLS_TEXT
	$HSplitContainer/Control/MarginContainer/VBoxContainer/HBoxContainer/CellCountsGraph/BoxContainer/Label.modulate = ThemeColors.TOOLS_TEXT
	$HSplitContainer/Control/MarginContainer/VBoxContainer/HBoxContainer/CellCountsGraph/ColorRect.color = ThemeColors.GAME_BG

func load_themes():
	var file = FileAccess.open("res://themes.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var json = JSON.new()
		var result = json.parse(content)
		if result != OK:
			print("Failed to parse JSON themes:", themes.error_string)
			return
		themes = json.data
		var theme_option_button = $SettingsPopup/VBoxContainer/HBoxContainer/OptionButton
		theme_option_button.clear()
		for theme_name in themes.keys():
			theme_option_button.add_item(theme_name)
	else:
		print("themes.json file not found")
