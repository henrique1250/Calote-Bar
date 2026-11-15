extends Control

@onready var mouse_cursor: Sprite2D = $MouseCursor
var pc_mouse_pos:Vector2 = Vector2.ZERO


func _ready() -> void:
	pass 



func _process(delta: float) -> void:
	pass


func update_cursor_pos():
	mouse_cursor.position = pc_mouse_pos
