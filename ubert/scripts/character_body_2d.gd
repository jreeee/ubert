class_name Player extends CharacterBody2D

@onready var sprite_bubble : Sprite2D = get_node("SpriteUbertBubble")
@onready var sprite_right : Sprite2D = get_node("SpriteUbertRight")
@onready var hitbox : CollisionPolygon2D = get_node("CollisionPolygon2D")
@onready var ui_canvas : Control = get_parent().get_node("UiKrams")
@onready var ui_depth : RichTextLabel = ui_canvas.get_node("UiDepth")
@onready var ui_oxygen : RichTextLabel = ui_canvas.get_node("UiOxygen")
@onready var ui_energy : RichTextLabel = ui_canvas.get_node("UiEnergy")
@onready var grabber : Area2D = get_node("Grabber")
@onready var vignette_tex_a : ColorRect = ui_canvas.get_node("VignetteA")
@onready var vignette_tex_b : Sprite2D = ui_canvas.get_node("VignetteB")
@onready var light_node : Node2D = get_node("LightPos")


@onready var mov_anim : AnimationPlayer = get_node("MovAnim")
@onready var bubble_anim : AnimationPlayer = get_node("BubbleAnim")
@onready var grab_anim : AnimationPlayer = get_node("GrabAnim")
@onready var vignette_mat : ShaderMaterial


var squished = false
var horizontal_speed := 200.0
var vertical_speed := 50
var rotation_speed := 1.0
var acceleration := 500.0
var deceleration := 400.0
var is_sprite_left := true

var energy_status := 100.0
var oxygen_status := 100.0
var depth_status := 0
var max_depth := 20 # can be upgraded
var grace := 200
# TODO sound stuff
var alarm_d1 := false
var alarm_d2 := false
var alarm_d3 := false

var grabber_cooldown = 2.0
var grabber_state = 0.0
var grabbable : bool = false

var array_ving
var ving_idx : int = 0 
var new_ving_idx := 0
var fade_t := 0.0
var fading := false
var zone_trigger := 0

var light_strength := 0.8
var light_on := false

var grabbed_obj : StaticBody2D

var mov_anim_state = "ubert_r"

var score = 0

func _ready() -> void:
	grabber.monitoring = true
	grabber.monitorable = true
	#array_ving = [	vignette_0, vignette_1, vignette_2, vignette_3, 
					#vignette_4, vignette_5, vignette_6 ,vignette_7,
					#vignette_8 ,vignette_9]
	vignette_tex_a.visible = true
	#vignette_tex_b.visible = true
	#vignette_tex_a.texture = array_ving[ving_idx]
	#vignette_tex_a.modulate.a = 1
	#vignette_tex_b.modulate.a = 0
	mov_anim.stop()
	vignette_mat = vignette_tex_a.material

func _grab() -> void:
	if grab_anim.is_playing() == false:
		grab_anim.play("ubert_grab")
		print("gaming")
		energy_status -= 2.0
	else:
		print("not so fast")
	if grabbable:
		var item_sprite = grabbed_obj.get_child(0)
		if item_sprite.name == "Trash":
			score += int(grabbed_obj.get_child(1).name)
			print(score)
			_pick_up(item_sprite)
		
func _pick_up(s: Sprite2D) -> void:
	await get_tree().create_timer(1.2).timeout
	print("pick")
	var tween = get_tree().create_tween()
	tween.tween_property(s, "position", -grabber.position, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	s.queue_free()
	grabbed_obj.get_parent().hide()

func _shine() -> void:
	if Input.is_action_just_released("ui_text_scroll_up"):
		light_strength = clamp(light_strength + .1, 0.5, 1)
	elif Input.is_action_just_released("ui_text_scroll_down"):
		light_strength = clamp(light_strength - .1, 0.5, 1)
	#radius = 0.2 + randf() * 0.02
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	print("stuff")
	#print(ui_canvas.get_canvas_transform().origin)
	var light = light_node.get_global_transform_with_canvas().origin/ screen_size
	#var screen_pos = get_viewport().get_camera_2d().unproject_position(global_position)
	#print(screen_pos)
	#var offset =  Vector2(-.087, -.09).rotated(rotation)  # TODO use node
	#var light = Vector2(0.5, 0.5) + offset
	var pos = mouse_pos / screen_size

	vignette_mat.set_shader_parameter("light_pos", light)

	var dir = (pos - light).normalized()
	vignette_mat.set_shader_parameter("light_dir", dir)
	energy_status -= 0.1 * light_strength
	print("shine bright " + str(dir)) 

func _darken(f: float) -> void:
		# simple fade in
		if f > 300.0 and f < 400.0:
			vignette_tex_a.modulate.a = clamp((f - 300.0) / 100.0, 0.0, 10.0)
			return
		if f < 500:
			return
		var new_ving_idx = clamp(int(f * 3 / 700), 0, array_ving.size() - 1)
		if new_ving_idx != ving_idx and not fading:
			zone_trigger = f
			print("ZT" + str(zone_trigger))
			var tex = array_ving[new_ving_idx]
			if tex:
				vignette_tex_b.texture = tex   # ✅ assign TO the sprite
				fading = true
		# cross fade
		var base_alpha = 1.0
		if fading:
			fade_t += abs(f - zone_trigger) / 10000
			print("FD" + str(fade_t))
			fade_t = clamp(fade_t, 0.0, 1.0)
			print("FD" + str(fade_t))
			var a_alpha = (1.0 - fade_t)
			var b_alpha = fade_t

			# urgh ugly
			var total = a_alpha + b_alpha
			if total > 0.0:
				a_alpha /= total * 3
				b_alpha /= total * 3
			vignette_tex_a.modulate.a = a_alpha * base_alpha
			vignette_tex_b.modulate.a = b_alpha * base_alpha

		if fade_t >= 1.0:
			# finalize
			vignette_tex_a.texture = vignette_tex_b.texture
			vignette_tex_a.modulate.a = base_alpha
			vignette_tex_b.modulate.a = 0.0

			ving_idx = new_ving_idx
			fade_t = 0.0
			fading = false
		else:
			# no crossfade → just apply base fade
			vignette_tex_a.modulate.a = base_alpha

# updating states
func _process(delta: float) -> void:
	# basic stuff for every tick
	ui_canvas.position = position
	depth_status = position.y * 0.05
	oxygen_status -= delta * 0.1
	if oxygen_status < 0:
		print("Game Over")
	#rint(position.y)
	if position.y < 20 and oxygen_status < 100:
		oxygen_status = clamp(oxygen_status + 2 * delta, 0.0, 100.0)
	#_darken(position.y)
	if Input.is_action_just_pressed("ui_grab"):
		_grab()
		
	if Input.is_action_pressed("ui_shine"):
		if not light_on:
			light_on = true
		_shine()
	else:
		if light_on:
			light_on = false
		
	# --- Grace ---
	var depth_delta  = max_depth - depth_status
	if depth_delta < 0:
		grace += depth_delta * delta
		#print("grace:" + str(grace))
	elif grace < 200 and depth_delta > 0:
		# fill grace back up
		grace += 80 * delta
		if grace >= 200:
			# reset alarms
			alarm_d1 = false
			alarm_d2 = false
			alarm_d3 = false
		#print("grace:" + str(grace))
	if grace < 200:
		if grace <= 200 and not alarm_d1:
			print("Uh oh")
			alarm_d1 = true
		if grace <= 100 and not alarm_d2:
			print("Not Good")
			alarm_d2 = true
		if grace <= 50 and not alarm_d3:
			print("Dude...")
			alarm_d3 = true
		if grace <= 0:
			print("Game Over")
			# TODO
	# update shader
	var curr_light = 0.0
	if light_on:
		curr_light = light_strength
	vignette_mat.set_shader_parameter("strength", curr_light)
	vignette_mat.set_shader_parameter("depth", position.y)
	# update UI
	clamp(energy_status, 0.0, 100.0)
	ui_depth.text = "[center]Depth: " + str(depth_status) + "/" + str(max_depth) + "[/center]"
	ui_oxygen.text = "[center]O_2: " + str("%3.1f" % oxygen_status) + "%[/center]"
	ui_energy.text = "[center]Energy: " + str("%3.1f" % energy_status) + "%[/center]"
# mainly input handling

func _physics_process(delta: float) -> void:
	# no sudden movement switches
	if grab_anim.is_playing():
		mov_anim.stop()
		velocity = Vector2.ZERO
		sprite_bubble.modulate.a = move_toward(sprite_bubble.modulate.a, 0.0, delta * 2)
		return
	var direction_r := Input.get_axis("ui_rotate_left", "ui_rotate_right")
	if direction_r:
		var rot = rotation + direction_r * rotation_speed * delta
		# prevent excessive tilt
		if rot > -0.6 and rot < 0.6:
			rotation = rot
		elif rot < (- PI + 0.6) or rot >  (PI - 0.6):
			rotation = rot

#	var local_coords = sprite.rotated
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := Vector2.RIGHT.rotated(rotation)
	if abs(rotation) > 2.5 and not is_sprite_left:
		direction = -direction #Vector2.RIGHT.rotated(-rotation)
	# axis movement inputs
	# respects the local rotation
	var direction_h := Input.get_axis("ui_left", "ui_right")
	var fwd := direction * horizontal_speed * direction_h
	
	# uses global y axis
	var direction_v := Input.get_axis("ui_up", "ui_down")
	var hrz := Vector2(0, vertical_speed * direction_v)
	# apply input (impulse based)

	if (direction_h or direction_v) and energy_status > 0:
		var target_velocity := fwd + hrz
		if Input.is_action_pressed("ui_cheat"):
			target_velocity *= 15
			energy_status += 20 * delta
			if not squished:
				scale *= 0.5
				squished = true
		else:
			if squished:
				scale *= 2.0
				squished = false
		# do not go above the water line
		if position.y < 0 and target_velocity.y < 0:
			target_velocity.y = 0
		# no movement allowed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		mov_anim.play("hubert_l")
		sprite_bubble.modulate.a = 1.0
		bubble_anim.play("hubert_bub")
		if energy_status < 0.2:
			energy_status = 0.0
		else:
			energy_status -= abs(velocity.length()) * 0.0002
	else:
		# decelerate
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		mov_anim.stop()
		sprite_bubble.modulate.a = move_toward(sprite_bubble.modulate.a, 0.0, delta * 3)
	#print(velocity)
	if velocity.x > 0 and is_sprite_left:
		rotation = -rotation
		scale.x = -1
		is_sprite_left = false

	elif velocity.x < 0 and not is_sprite_left:
		rotation = -rotation
		scale.x = 1
		is_sprite_left = true
	
	move_and_slide()


func _on_grabber_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Item":
		grabbable = true
		grabbed_obj = body


func _on_grabber_body_exited(body: Node2D) -> void:
	print(body.name)
	if body.name == "Item":
		grabbable = false
		grabbed_obj = null
