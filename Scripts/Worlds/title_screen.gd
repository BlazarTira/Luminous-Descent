extends Control

@onready var quit_disabled = $"../quit_disabled"
@onready var preview_sprite = $"../Color_Select/AnimatedSprite2D"
@onready var left_button = $"../Color_Select/Left_Button"
@onready var right_button = $"../Color_Select/Right_Button"


var colors = [
	Color(1, 0, 0),  # Red
	Color(0, 1, 0),  # Green
	Color(0.2, 0.3, 1),  # Blue
	Color(1, 1, 0),  # Yellow
	Color(1, 0, 1),  # Purple
	Color(0, 1, 1)   # Cyan
]
var current_color_index = 0

func _ready():
	update_preview()

func _on_play_pressed():
	Global.selected_color = colors[current_color_index]
	get_tree().change_scene_to_file("res://Scenes/Worlds/hub.tscn")


func _on_quit_pressed():
	#get_tree().quit()
	pass

func _on_quit_mouse_entered():
	quit_disabled.show()


func _on_quit_mouse_exited():
	quit_disabled.hide()


func _on_left_button_pressed():
	current_color_index = (current_color_index - 1 + colors.size()) % colors.size()
	update_preview()


func _on_right_button_pressed():
	current_color_index = (current_color_index + 1) % colors.size()
	update_preview()

func update_preview():
	preview_sprite.modulate = colors[current_color_index]
