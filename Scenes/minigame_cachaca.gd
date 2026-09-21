extends CanvasLayer

@export var velocidade_medidor := 100.0
@export var largura_medidor := 80.0
@export var largura_alvo := 50.0
@export var altura_medidor := 400.0
@export var altura_alvo := 50.0

@export var tempo_necessario := 1.5

#Configuração do Alvo
@export var impulso_alvo := 200.0
@export var atrito_alvo := 0.95
@export var variacao_impulso := 100.0
@export var gravidade_alvo := 300.0

@export var contador: Label

#Variáveis do alvo
var barra_y  := 0.0
var direcao := 1.0
var minigame_ativado := false

var alvo_y := 0.0
var alvo_velocidade := 0.0
var alvo_direcao := 0.0

var tempo_acumulado_no_alvo := 0.0

@onready var alvo = $Alvo
@onready var medidor = $Medidor_Externo
@onready var barra_movel = $Medidor_Externo/Medidor_Interno
@onready var resultado_label = $ResultadoLabel
@onready var painel = $Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	painel.visible = false
	resultado_label.visible = false
	alvo.visible = false
	medidor.visible = false
	barra_movel.visible = false
	
	var tela = get_viewport().size
	
	#Posição do Painel
	var painel_largura = 400
	var painel_altura = 1000
	painel.size = Vector2(painel_largura, painel_altura)
	painel.position = Vector2((tela.x - painel_largura) / 2.0, (tela.y - painel_altura) / 2.0)
	
	#Posição da label do final do game
	var label_largura = 300
	var label_altura = 60
	resultado_label.size = Vector2(label_largura, label_altura)
	resultado_label.position = Vector2((tela.x - label_largura) / 2.0, (tela.y - label_altura) / 2.0)
	resultado_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resultado_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resultado_label.add_theme_font_size_override("font_size", 32)
	
	#Posição do medidor externo
	medidor.size = Vector2(largura_medidor, altura_medidor)
	medidor.position.x = (tela.x - largura_medidor) / 2
	medidor.position.y = (tela.y - altura_medidor) / 2
	
	#Posição do alvo
	alvo.size = Vector2(largura_alvo, altura_alvo)
	alvo.position.x = medidor.position.x + ((largura_medidor - largura_alvo) / 2.0)
	alvo_y = altura_medidor - altura_alvo - 2.0
	alvo.position.y = medidor.position.y + alvo_y
	
	#Posição do medidor interno
	barra_movel.size = Vector2(largura_medidor - 4, 20)
	barra_movel.position.x = 2
	barra_movel.position.y = 0
	barra_y = 0
	
	#Iniciando as variáveis do alvo
	alvo_velocidade = 0
	alvo_direcao = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not minigame_ativado:
		return
	
	barra_y += velocidade_medidor * delta * direcao
	barra_movel.position.y = barra_y
	
	if barra_y <= 0:
		direcao = 1
	elif barra_y >= altura_medidor - barra_movel.size.y:
		direcao = -1
	
	_atualizar_alvo(delta)
	verificar_timing(delta)
		
func _atualizar_alvo(delta: float) -> void:
	#Aplicando Forças
	alvo_velocidade += gravidade_alvo * delta
	alvo_velocidade *= pow(atrito_alvo, delta * 60.0)
	alvo_y += alvo_velocidade * delta
	
	#Definindo os limites
	var altura_min_lim = 0.0
	var altura_max_lim = altura_medidor - altura_alvo - 2
	
	if alvo_y <= altura_min_lim:
		alvo_y = altura_min_lim
		alvo_velocidade = 0
	elif alvo_y >= altura_max_lim:
		alvo_y = altura_max_lim
		alvo_velocidade = 0
	
	alvo.position.y = medidor.position.y + alvo_y
	
func _input(event: InputEvent):
	if not minigame_ativado:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_aplicar_impulso()

func _aplicar_impulso():
	#Atualizar Impulso
	var forca_impulso = impulso_alvo + randf_range(-variacao_impulso, variacao_impulso)
	
	alvo_velocidade = -forca_impulso
	
	print("🐟 Alvo impulsionado! Velocidade:", alvo_velocidade)
	
func verificar_timing(delta: float) -> void:
	var rect_barra = barra_movel.get_global_rect()
	var rect_alvo = alvo.get_global_rect()
	
	# Descomente esta linha para ver as posições reais e tamanhos no Output:
	#print("Barra: ", rect_barra, " | Alvo: ", rect_alvo)
	
	if rect_barra.intersects(rect_alvo):
		tempo_acumulado_no_alvo += delta
		print("Dentro!")
		
		if tempo_acumulado_no_alvo >= tempo_necessario:
			sucesso()
	else:
		tempo_acumulado_no_alvo = max(0.0, tempo_acumulado_no_alvo - delta * 0.5)

func sucesso():
	minigame_ativado = false
	resultado_label.text = "ACERTOU!"
	resultado_label.modulate = Color.GREEN
	resultado_label.visible = true
	
	if Engine.has_singleton("ContadorGlobal") or get_node_or_null("/root/ContadorGlobal"):
		ContadorGlobal.incrementar(5)
	print("Acertou")
	
	await get_tree().create_timer(1.0).timeout
	
	fechar_minigame()
	
func falha():
	minigame_ativado = false
	resultado_label.text = "FIADO!"
	resultado_label.modulate = Color.RED
	resultado_label.visible = true
	print("ERROU!")
	
	if Engine.has_singleton("ContadorGlobal") or get_node_or_null("/root/ContadorGlobal"):
		ContadorGlobal.incrementar(0)  
	
	await get_tree().create_timer(1.0).timeout
	
	fechar_minigame()
	
func ativar_minigame():
	minigame_ativado = true
	alvo.visible = true
	medidor.visible = true
	painel.visible = true
	resultado_label.visible = false
	barra_movel.visible = true
	
	barra_y = 0
	barra_movel.position.y = barra_y
	direcao = 1
	
	alvo_y = altura_medidor - altura_alvo - 2
	alvo.position.y = medidor.position.y + alvo_y
	alvo_velocidade = 0
	alvo_direcao = 0
	
	print("MINIGAME ATIVADO")
	
func fechar_minigame():
	minigame_ativado = false
	painel.visible = false
	alvo.visible = false
	medidor.visible = false
	resultado_label.visible = false
	barra_movel.visible = false
	print("Jogo Fechado")
