extends Node3D

@onready var anim_player = $AnimationPlayer

const SEQUENCIA_ANIMACAO = ["Garcom/Encostado", "Garcom/Balcao_Limpo", "Garcom/Encostado", "Garcom/Copor_Limpo"]
var indice_atual = 0

func _ready():
	anim_player.animation_finished.connect(_ao_terminar_animacao)
	tocar_proxima_animacao()

func tocar_proxima_animacao():
	var nome_animacao = SEQUENCIA_ANIMACAO[indice_atual]
	anim_player.play(nome_animacao)
	
func _ao_terminar_animacao(_anim_name: StringName):
	indice_atual = (indice_atual + 1) % SEQUENCIA_ANIMACAO.size()
	
	tocar_proxima_animacao()
