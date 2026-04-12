extends Node2D

@export var sprite : Texture2D
@export var item : String
@export var amount : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var instance_sprite = $Item.get_child(0)
	instance_sprite.texture = sprite
	instance_sprite.name = item
	var instance_type = $Item.get_child(1)
	instance_type.name = amount
