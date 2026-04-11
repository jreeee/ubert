class_name Box extends Node2D

@onready var area : Area2D = get_node("Area2D")
@export var visited : bool = false
@export var tex_base : Texture2D
@export var tex_hover : Texture2D
@export var tex_select : Texture2D
@export var tex_gray : Texture2D

@export var desc : String
@export var poi_name : String

var is_player_inside := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# instantiation stuff
	area.monitoring = true
	area.monitorable = true
	$Sprite2D.texture = tex_base
	$RichTextLabel.text = desc

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_player_inside and Input.is_action_just_pressed("ui_select"):
		print("in Option " + poi_name)
		select()

func select() -> void:
	visited = true
	$Sprite2D.texture = tex_select
		
func _on_area_2d_body_entered(body):
	if body.name == "Ubert":
		is_player_inside = true
		$Sprite2D.texture = tex_hover
		
func _on_area_2d_body_exited(body):
	print(body.name)
	if body.name == "Ubert":
		is_player_inside = false
		$Sprite2D.texture = tex_base
