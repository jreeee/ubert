class_name PointOfInterest extends Node2D

@onready var area : Area2D = get_node("Area2D")
@export var visited : bool = false
@export var sprite_tex : Texture2D
@export var desc : String
@export var poi_name : String


var is_player_inside := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# instantiation stuff
	area.monitoring = true
	area.monitorable = true
	$Sprite2D.texture = sprite_tex

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_player_inside and Input.is_action_just_pressed("ui_select"):
		print("in POI " + poi_name)
		visit()

func visit() -> void:
	if visited == false:
		visited = true
		area.monitoring = false
		$Sprite2D.modulate = Color(0.5, 0.5, 0.5)
		
func _on_area_2d_body_entered(body):
	print(body.name)
	if body.name == "Ubert":
		is_player_inside = true
		
func _on_area_2d_body_exited(body):
	print(body.name)
	if body.name == "Ubert":
		is_player_inside = false
