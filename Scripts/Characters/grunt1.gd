extends CharacterBody2D

const chase_speed = 200
const jump_height = -500
@onready var Player = get_tree().get_first_node_in_group("Player")
@onready var Player_Char = get_tree().get_first_node_in_group("Player").get_child(0)
var player_dir = 0
var chase = false

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Player_Char.global_position.x > global_position.x:
		player_dir = 1
	elif Player_Char.global_position.x < global_position.x:
		player_dir = -1
	
	if chase == true:
		velocity.x = move_toward(0, Player_Char.global_position.x * player_dir, chase_speed)
	elif chase == false:
		velocity.x = 0
		
	if is_on_wall() and is_on_floor():
		velocity.y = jump_height
		
	move_and_slide()

func _on_detection_range_body_entered(body: Node2D) -> void: #Only chases in initial direction
	if body.get_parent().is_in_group("Player"):
		chase = true
		
func _on_detection_range_body_exited(body: Node2D) -> void:
	if body.get_parent().is_in_group("Player"):
		chase = false
