extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file("res://Scenes/Worlds/Floor1.tscn")
