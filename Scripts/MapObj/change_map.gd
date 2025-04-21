extends CollisionShape2D
@onready var map_name = get_parent().get_parent().name

func _on_stage_change_body_entered(body: Node2D) -> void:
	if body.get_parent().is_in_group("Player"):
		if map_name == "Level 1":
			get_tree().change_scene_to_file("res://Scenes/Maps/TestMap.tscn")
