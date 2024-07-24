extends Control

@onready var quit_disabled = $"../quit_disabled"

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Worlds/Floor1.tscn")


func _on_quit_pressed():
	#get_tree().quit()
	pass

func _on_quit_mouse_entered():
	quit_disabled.show()


func _on_quit_mouse_exited():
	quit_disabled.hide()
