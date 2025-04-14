extends CharacterBody2D

var detection_set = false
var falling = false
var cant_get_up = false
const fall_speed = 1000
@onready var Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	#Big number as a placeholder
	$PlayerDetect.target_position.y = 10000
	
func _process(delta: float) -> void:
	if falling == false:
		velocity = Vector2(0, 0)
	#Set up raycasting point to the floor
	if detection_set == false:
		var floor_point = $PlayerDetect.get_collision_point()
		$PlayerDetect.target_position.y = floor_point.y
		$PlayerDetect.set_collision_mask_value(1, false)
		detection_set = true
		await get_tree().create_timer(0.5).timeout
	
	#Fall when the player runs under
	if $PlayerDetect.is_colliding() and detection_set == true:
		is_player()
		if $PlayerDetect.get_collider() == Player:
			velocity.y = move_toward(0, $PlayerDetect.target_position.y, fall_speed)
			falling = true
	
	if is_on_floor():
		falling = false
		cant_get_up = true
		velocity.y = 0
		velocity.x = 0
	
	move_and_slide()

func is_player():
	if $PlayerDetect.is_colliding():
		Player = $PlayerDetect.get_collider()
		return $PlayerDetect.get_collider()


func _on_area_2d_body_entered(body: Node2D) -> void: #Attempt at hurting player
	if body.get_parent().is_in_group("Player") and falling == true:
		print("owie! :(")
		get_parent().queue_free()
		
