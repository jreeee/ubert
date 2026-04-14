class_name Main extends Node2D

@onready var wave_1 : Sprite2D = get_node("Btm_wave_l1")
@onready var wave_2 : Sprite2D = get_node("Btm_wave_l2")
@onready var wave_3 : Sprite2D = get_node("Btm_wave_l3")

@export var tex_wave_1 : Texture2D
@export var tex_wave_2 : Texture2D
@export var tex_wave_3 : Texture2D
@export var tex_wave_4 : Texture2D

@onready var ship : Sprite2D = get_node("Ship")


var array
var wave_1_idx : int = 0
var wave_2_idx : int = 2
var wave_3_idx : int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	array = [tex_wave_1, tex_wave_2, tex_wave_3, tex_wave_4]

var offset1 = 0
var offset2 = 2.1
var offset3 = 1.2

var timer : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wave_1.texture = array[wave_1_idx]
	wave_2.texture = array[wave_2_idx]
	wave_3.texture = array[wave_3_idx]
	offset1 += delta * randi_range(3, 8)
	offset2 -= delta * randi_range(4, 10)
	offset3 += delta * randi_range(2, 7)
	wave_2.position.x += 0.15 * sin(offset1)
	wave_2.position.y -= 0.1 * sin(offset2)
	wave_1.position.x += 0.11 * cos(offset3)
	wave_1.position.y += 0.07 * sin(offset1)
	wave_3.position.x += 0.26 * sin(offset2)
	wave_3.position.y -= 0.12 * cos(offset1)
	ship.position.x += 0.3 * cos(offset2/10.0)
	ship.position.y -= 0.03 * sin(offset3/10.0)
	timer += 1
	if timer % 11 == 0:
		wave_1_idx = (wave_1_idx + 1) % 4
	if timer % 13 == 0:
		wave_2_idx = (wave_2_idx + 1) % 4
	if timer % 17 == 0:
		wave_3_idx = (wave_3_idx + 1) % 4
