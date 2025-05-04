extends Control

@onready var Player = get_tree().get_first_node_in_group("Player").get_child(0)
@onready var PlayerHP = Player.health
@onready var HPBar = $CanvasLayer/TextureProgressBar

func _ready() -> void:
	Player.dmg_taken.connect(_on_player_damaged)
	pass
	
func _process(delta: float) -> void:
	PlayerHP = Player.health
	
func _on_player_damaged():
	HPBar.value = PlayerHP
	
