extends Control

@onready var mouse_cursor: Sprite2D = $MouseCursor
var pc_mouse_pos:Vector2 = Vector2.ZERO
@onready var meta: Panel = $Meta
@onready var mensagens_painel: Panel = $Mensagens_Painel
@onready var loja_painel: Panel = $Loja_Painel

var pc_using: PCStatic
@onready var button: Button = $Button


func _ready() -> void:
	
	meta.visible = false;
	mensagens_painel.visible = false;
	loja_painel.visible = false;


func _process(delta: float) -> void:
	pass


func update_cursor_pos():
	mouse_cursor.position = pc_mouse_pos
	

func _on_button_pressed() -> void:
	meta.visible = !meta.visible


func _on_mensagens_pressed() -> void:
	mensagens_painel.visible = !mensagens_painel.visible
	


func _on_loja_pressed() -> void:
	loja_painel.visible = !loja_painel.visible
