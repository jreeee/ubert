extends CharacterBody2D

@onready var sprite_left : Sprite2D = get_node("SpriteUbertLeft")
@onready var sprite_right : Sprite2D = get_node("SpriteUbertRight")

var horizontal_speed := 200.0
var vertical_speed := 50.0
var rotation_speed := 1.0
var acceleration := 500.0
var deceleration := 400.0
var is_sprite_left := true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	var direction_r := Input.get_axis("ui_rotate_left", "ui_rotate_right")
	if direction_r:
		var rot = rotation + direction_r * rotation_speed * delta
		# prevent excessive tilt
		if rot > -0.6 and rot < 0.6:
			rotation = rot
#	var local_coords = sprite.rotated
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2.RIGHT.rotated(rotation)
	
	# axis movement inputs
	# respects the local rotation
	var direction_h := Input.get_axis("ui_left", "ui_right")
	var fwd := direction * horizontal_speed * direction_h
	# uses global y axis
	var direction_v := Input.get_axis("ui_up", "ui_down")
	var hrz := Vector2(0, vertical_speed * direction_v)
	# apply input (impulse based)
	if direction_h or direction_v:
		var target_velocity := fwd + hrz
		# do not go above the water line
		if position.y < 0 and target_velocity.y < 0:
			target_velocity.y = 0
		print(target_velocity)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# decelerate
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	print(velocity)
	if velocity.x > 0 and is_sprite_left:
		is_sprite_left = false
		sprite_left.visible = false
		sprite_right.visible = true
		rotation = -rotation
	elif velocity.x < 0 and not is_sprite_left:
		is_sprite_left = true
		sprite_right.visible = false
		sprite_left.visible = true
		rotation = -rotation
	move_and_slide()
