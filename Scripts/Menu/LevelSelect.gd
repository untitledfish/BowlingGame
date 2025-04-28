extends Button

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Maps/Level_1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Maps/Level_2.tscn")

func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Maps/Level_3.tscn")
