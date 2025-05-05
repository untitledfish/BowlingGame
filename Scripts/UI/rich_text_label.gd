extends Label

@onready var player = get_tree().get_first_node_in_group("Player") as CharacterBody2D

func _process(delta):
	if player and player.has_variable("kill_count"):
		text = "Kills: " + str(player.kill_count)
