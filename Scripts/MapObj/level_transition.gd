extends Area2D

@export var target_scene: PackedScene  # Set this in the editor

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player") and target_scene:
		print("Transitioning to next level...")
		get_tree().change_scene_to_packed(target_scene)
