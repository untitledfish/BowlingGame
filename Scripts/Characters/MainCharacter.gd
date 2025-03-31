extends CharacterBody2D

#Variables
const walk_speed = 300
const run_speed = 500
const dash_speed = 2000
const jump_height = -500
var last_input = 0
var can_dash = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#Move left and right. If Shift is held, move faster
	var move_input = Input.get_axis("ui_left", "ui_right")
	if move_input and Input.is_action_pressed("Run"):
		velocity.x = move_input * run_speed
	elif move_input:
		velocity.x = move_input * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0 , walk_speed)
	
	#Floor check
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Jumping (Space)
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_height
	
	#Dashing, feels too instant so will work on it more (K)
	if Input.is_action_just_pressed("Dash") and move_input and (can_dash == true):
		last_input = move_input
		velocity = velocity.move_toward(Vector2(last_input * dash_speed, 0), dash_speed)
		velocity.y = -9.8
		await get_tree().create_timer(0.5).timeout
		can_dash = false
		$DashCD.start()
		
	move_and_slide()

#Dash cooldown
func _on_dash_cd_timeout() -> void:
	print("Dash ready!")
	can_dash = true
