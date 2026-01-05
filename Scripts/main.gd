extends Node

@export var menu_principal: PackedScene
@export var como_jogar: PackedScene


const circle := preload("res://Scenes/circle.tscn")
const cross := preload("res://Scenes/x.tscn")
const icon := preload("res://Assets/vecteezy_geometric-design-element_21048718.png")

var turn_counter := 0
var whos_turn_is_it: Node  # De quem é a vez de jogar atualmente
var player_turn_order  # Se o jogador terá turnos ímpares ou pares
var player_symbol: String
var cpu_symbol: String
var symbols_attached # [0] = player [1] = CPU
var rng := RandomNumberGenerator.new()
var dicts_symbols := {"A1": null, "A2": null, "A3": null,
					"B1": null, "B2": null, "B3": null, 
					"C1": null, "C2": null, "C3": null
					}
var game_ended := false
var game_restarted := false
var winner
var winner_symbol
var new_menu: Node
var new_how_to_play: Node
var game_just_started := true
var last_slot

# Buttons
var offset_button_x := 20
var offset_button_y := 75
var button_symbol_scale := Vector2(1.15,1.15)
#---------------------------------------#

# Audio
var audios_finished := 0  # Controle para intercalação entre áudio e ação no jogo
var control := true  # Controle para o áudio reproduzido no primeiro turno
@onready var e_a_vez_do: Object = $Audio/E_a_vez_do
@onready var j1_circle: Object = $Audio/Jogador_1_circulo
@onready var j1_x: Object = $Audio/Jogador_1_x
@onready var j1: Object = $Audio/Jogador_1
@onready var cpu: Object = $Audio/Cpu
@onready var posicionou_na_casa: Object = $Audio/Posicionou_na_casa
@onready var vencedor_e: Object = $Audio/Vencedor_e
@onready var empate: Object = $Audio/Empate
@onready var fim_de_partida: Object = $Audio/Fim_de_partida
@onready var inicio_partida: Object = $Audio/Inicio_partida
@onready var partida_reiniciada: Object = $Audio/Partida_reiniciada
#---------------------------------------#

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$CPU.audio_casa_finished.connect(_on_casa_finished)
	go_to_menu()
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart_game"):  # Reinicia a partida "R"
		if not new_menu and not new_how_to_play:
			for button in get_tree().get_nodes_in_group("navigation_buttons"):
				if not button.disabled:
					game_restarted = true
					prepare_game()
			if game_ended:
				game_restarted = true
				prepare_game()
					
	elif Input.is_action_just_pressed("main_menu"):
		if not new_menu:
			go_to_menu()
			
			if new_how_to_play:  # Se estiver na tela "Como Jogar", deleta a mesma
				new_how_to_play.queue_free()
	
	# Para pegar o valor $Player.last_slot_used somente quando ele mudar de valor
	if not game_ended:
		if last_slot != $Player.last_slot_used:
			last_slot = $Player.last_slot_used
	else:
		if get_tree().get_node_count_in_group("navigation_buttons") > 0:
			for button in get_tree().get_nodes_in_group("navigation_buttons"):
				button.disabled = true



# Função para instanciar e posicionar o símbolo na casa selecionada
func _button_symbol_pressed(slot, current_player_symbol):

	if current_player_symbol == "Circle":
		var new_circle := circle.instantiate()
		new_circle.set_global_position(slot.get_parent().get_parent().global_position)
		self.add_child(new_circle)
		new_circle.add_to_group("symbols")
	else:
		var new_cross := cross.instantiate()
		new_cross.set_global_position(slot.get_parent().get_parent().global_position)
		self.add_child(new_cross)
		new_cross.add_to_group("symbols")
	
	var slot_used_string = slot.get_parent().get_parent().to_string().left(2)
	dicts_symbols[slot_used_string] = current_player_symbol  # Key recebe o value do símbolo posicionado
	
	if current_player_symbol == $Player.symbol_attached:
		$Player.last_slot_used = slot_used_string
	if current_player_symbol == $CPU.symbol_attached:
		$CPU.last_slot_used = slot_used_string

	var button = slot  # Variável para função rearrange_menu
	var button_parent = slot.get_parent()
	
	slot.queue_free()

	# Aguarda a deleção do objeto para rodar a função rearrange_menu
	while slot != null:
		await get_tree().process_frame

	check_game_end()
	rearrange_menu(button, button_parent)
	
	mediate_turns()


# Gera os botões que permitem posicionar os símbolos
func gen_buttons_symbols(symbols_attached, dicts_symbols):
	var button_symbol_text := ""
	if symbols_attached[0] == "Circle":
		button_symbol_text = "Posicionar ○ aqui"
	else:
		button_symbol_text = "Posicionar X aqui"
	
	var button_a1 := Button.new()
	button_a1.text = button_symbol_text
	$Board/HitboxesA/A1/A1.add_child(button_a1)
	button_a1.position = button_a1.position - button_a1.size / 2
	button_a1.position.x = button_a1.position.x + offset_button_x
	button_a1.position.y = button_a1.position.y + offset_button_y
	button_a1.scale = button_symbol_scale
	button_a1.pressed.connect(_button_symbol_pressed.bind(button_a1, symbols_attached[0]))

	var button_a2 := Button.new()
	button_a2.text = button_symbol_text
	$Board/HitboxesA/A2/A2.add_child(button_a2)
	button_a2.position = button_a2.position - button_a2.size / 2
	button_a2.position.x = button_a2.position.x + offset_button_x
	button_a2.position.y = button_a2.position.y + offset_button_y
	button_a2.scale = button_symbol_scale
	button_a2.pressed.connect(_button_symbol_pressed.bind(button_a2, symbols_attached[0]))
	
	var button_a3 := Button.new()
	button_a3.text = button_symbol_text
	$Board/HitboxesA/A3/A3.add_child(button_a3)
	button_a3.position = button_a3.position - button_a3.size / 2
	button_a3.position.x = button_a3.position.x + offset_button_x
	button_a3.position.y = button_a3.position.y + offset_button_y
	button_a3.scale = button_symbol_scale
	button_a3.pressed.connect(_button_symbol_pressed.bind(button_a3, symbols_attached[0]))

	var button_b1 := Button.new()
	button_b1.text = button_symbol_text
	$Board/HitboxesB/B1/B1.add_child(button_b1)
	button_b1.position = button_b1.position - button_b1.size / 2
	button_b1.position.x = button_b1.position.x + offset_button_x
	button_b1.position.y = button_b1.position.y + offset_button_y
	button_b1.scale = button_symbol_scale
	button_b1.pressed.connect(_button_symbol_pressed.bind(button_b1, symbols_attached[0]))
	
	var button_b2 := Button.new()
	button_b2.text = button_symbol_text
	$Board/HitboxesB/B2/B2.add_child(button_b2)
	button_b2.position = button_b2.position - button_b2.size / 2
	button_b2.position.x = button_b2.position.x + offset_button_x
	button_b2.position.y = button_b2.position.y + offset_button_y
	button_b2.scale = button_symbol_scale
	button_b2.pressed.connect(_button_symbol_pressed.bind(button_b2, symbols_attached[0]))

	var button_b3 := Button.new()
	button_b3.text = button_symbol_text
	$Board/HitboxesB/B3/B3.add_child(button_b3)
	button_b3.position = button_b3.position - button_b3.size / 2
	button_b3.position.x = button_b3.position.x + offset_button_x
	button_b3.position.y = button_b3.position.y + offset_button_y
	button_b3.scale = button_symbol_scale
	button_b3.pressed.connect(_button_symbol_pressed.bind(button_b3, symbols_attached[0]))
	
	var button_c1 := Button.new()
	button_c1.text = button_symbol_text
	$Board/HitboxesC/C1/C1.add_child(button_c1)
	button_c1.position = button_c1.position - button_c1.size / 2
	button_c1.position.x = button_c1.position.x + offset_button_x
	button_c1.position.y = button_c1.position.y + offset_button_y
	button_c1.scale = button_symbol_scale
	button_c1.pressed.connect(_button_symbol_pressed.bind(button_c1, symbols_attached[0]))
	
	var button_c2 := Button.new()
	button_c2.text = button_symbol_text
	$Board/HitboxesC/C2/C2.add_child(button_c2)
	button_c2.position = button_c2.position - button_c2.size / 2
	button_c2.position.x = button_c2.position.x + offset_button_x
	button_c2.position.y = button_c2.position.y + offset_button_y
	button_c2.scale = button_symbol_scale
	button_c2.pressed.connect(_button_symbol_pressed.bind(button_c2, symbols_attached[0]))
	
	var button_c3 := Button.new()
	button_c3.text = button_symbol_text
	$Board/HitboxesC/C3/C3.add_child(button_c3)
	button_c3.position = button_c3.position - button_c3.size / 2
	button_c3.position.x = button_c3.position.x + offset_button_x
	button_c3.position.y = button_c3.position.y + offset_button_y
	button_c3.scale = button_symbol_scale
	button_c3.pressed.connect(_button_symbol_pressed.bind(button_c3, symbols_attached[0]))

	# Botões ficarão no grupo para melhor organização
	button_a1.add_to_group("navigation_buttons")
	button_a2.add_to_group("navigation_buttons")
	button_a3.add_to_group("navigation_buttons")
	button_b1.add_to_group("navigation_buttons")
	button_b2.add_to_group("navigation_buttons")
	button_b3.add_to_group("navigation_buttons")
	button_c1.add_to_group("navigation_buttons")
	button_c2.add_to_group("navigation_buttons")
	button_c3.add_to_group("navigation_buttons")

	# Configuração da navegação do menu pelo teclado
	button_a1.grab_focus()
	
	button_a1.set_focus_neighbor(2, button_b1.get_path())
	button_a1.set_focus_neighbor(3, button_a2.get_path())
	
	button_b1.set_focus_neighbor(0, button_a1.get_path())
	button_b1.set_focus_neighbor(2, button_c1.get_path())
	button_b1.set_focus_neighbor(3, button_b2.get_path())
	
	button_c1.set_focus_neighbor(0, button_b1.get_path())
	button_c1.set_focus_neighbor(3, button_c2.get_path())
	
	button_a2.set_focus_neighbor(1, button_a1.get_path())
	button_a2.set_focus_neighbor(2, button_b2.get_path())
	button_a2.set_focus_neighbor(3, button_a3.get_path())
	
	button_b2.set_focus_neighbor(0, button_a2.get_path())
	button_b2.set_focus_neighbor(1, button_b1.get_path())
	button_b2.set_focus_neighbor(2, button_c2.get_path())
	button_b2.set_focus_neighbor(3, button_b3.get_path())
	
	button_c2.set_focus_neighbor(0, button_b2.get_path())
	button_c2.set_focus_neighbor(1, button_c1.get_path())
	button_c2.set_focus_neighbor(3, button_c3.get_path())
	
	button_a3.set_focus_neighbor(1, button_a2.get_path())
	button_a3.set_focus_neighbor(2, button_b3.get_path())
	
	button_b3.set_focus_neighbor(0, button_a3.get_path())
	button_b3.set_focus_neighbor(1, button_b2.get_path())
	button_b3.set_focus_neighbor(2, button_c3.get_path())
	
	button_c3.set_focus_neighbor(0, button_b3.get_path())
	button_c3.set_focus_neighbor(1, button_c2.get_path())
	
	if game_restarted:
		partida_reiniciada.play()
	else:
		inicio_partida.play()
	for button in get_tree().get_nodes_in_group("navigation_buttons"):
			button.disabled = true

func rearrange_menu(button_deleted, button_parent):
	if get_tree().get_node_count_in_group("navigation_buttons") > 0:
		var button_0 := get_tree().get_nodes_in_group("navigation_buttons")[0]
		# O primeiro botão válido pega foco do cursor
		button_0.grab_focus()

	#  Troca de vizinhos quando alguma casa é ocupada, para evitar problemas de navegação com teclado
	if button_parent == $Board/HitboxesA/A1/A1:
		if $Board/HitboxesA/A2/A2.get_child(0) and $Board/HitboxesB/B1/B1.get_child(0):
			$Board/HitboxesA/A2/A2.get_child(0).set_focus_neighbor(1, $Board/HitboxesB/B1/B1.get_child(0).get_path())
	elif button_parent == $Board/HitboxesA/A2/A2:
		if $Board/HitboxesA/A1/A1.get_child(0) and $Board/HitboxesA/A3/A3.get_child(0):
			$Board/HitboxesA/A1/A1.get_child(0).set_focus_neighbor(3, $Board/HitboxesA/A3/A3.get_child(0).get_path())
			$Board/HitboxesA/A3/A3.get_child(0).set_focus_neighbor(1, $Board/HitboxesA/A1/A1.get_child(0).get_path())
	elif button_parent == $Board/HitboxesA/A3/A3:
		if $Board/HitboxesA/A2/A2.get_child(0) and $Board/HitboxesB/B3/B3.get_child(0):
			$Board/HitboxesA/A2/A2.get_child(0).set_focus_neighbor(3, $Board/HitboxesB/B3/B3.get_child(0).get_path())
	elif button_parent == $Board/HitboxesB/B1/B1:
		if $Board/HitboxesA/A1/A1.get_child(0) and $Board/HitboxesA/A3/A3.get_child(0) and $Board/HitboxesC/C1/C1.get_child(0):
			$Board/HitboxesA/A1/A1.get_child(0).set_focus_neighbor(2, $Board/HitboxesC/C1/C1.get_child(0).get_path())
			$Board/HitboxesC/C1/C1.get_child(0).set_focus_neighbor(0, $Board/HitboxesA/A1/A1.get_child(0).get_path())
	elif button_parent == $Board/HitboxesB/B2/B2:
		if $Board/HitboxesA/A2/A2.get_child(0) and $Board/HitboxesC/C2/C2.get_child(0):
			$Board/HitboxesA/A2/A2.get_child(0).set_focus_neighbor(2, $Board/HitboxesC/C2/C2.get_child(0).get_path())
			$Board/HitboxesC/C2/C2.get_child(0).set_focus_neighbor(0, $Board/HitboxesA/A2/A2.get_child(0).get_path())
		if $Board/HitboxesB/B1/B1.get_child(0) and $Board/HitboxesB/B3/B3.get_child(0):
			$Board/HitboxesB/B1/B1.get_child(0).set_focus_neighbor(3, $Board/HitboxesB/B3/B3.get_child(0).get_path())
			$Board/HitboxesB/B3/B3.get_child(0).set_focus_neighbor(1, $Board/HitboxesB/B1/B1.get_child(0).get_path())
	elif button_parent == $Board/HitboxesB/B3/B3:
		if $Board/HitboxesA/A3/A3.get_child(0) and $Board/HitboxesC/C3/C3.get_child(0):
			$Board/HitboxesA/A3/A3.get_child(0).set_focus_neighbor(2, $Board/HitboxesC/C3/C3.get_child(0).get_path())
			$Board/HitboxesC/C3/C3.get_child(0).set_focus_neighbor(0, $Board/HitboxesA/A3/A3.get_child(0).get_path())
	elif button_parent == $Board/HitboxesC/C1/C1:
		if $Board/HitboxesB/B1/B1.get_child(0) and $Board/HitboxesC/C2/C2.get_child(0):
			$Board/HitboxesC/C2/C2.get_child(0).set_focus_neighbor(1, $Board/HitboxesB/B1/B1.get_child(0).get_path())
	elif button_parent == $Board/HitboxesC/C2/C2:
		if $Board/HitboxesC/C1/C1.get_child(0) and $Board/HitboxesC/C3/C3.get_child(0):
			$Board/HitboxesC/C1/C1.get_child(0).set_focus_neighbor(3, $Board/HitboxesC/C3/C3.get_child(0).get_path())
			$Board/HitboxesC/C3/C3.get_child(0).set_focus_neighbor(1, $Board/HitboxesC/C1/C1.get_child(0).get_path())
	elif button_parent == $Board/HitboxesC/C3/C3:
		if $Board/HitboxesC/C2/C2.get_child(0) and $Board/HitboxesB/B3/B3.get_child(0):
			$Board/HitboxesC/C2/C2.get_child(0).set_focus_neighbor(3, $Board/HitboxesB/B3/B3.get_child(0).get_path())
		

# Os símbolos posicionados em cada casa será armazenado em um dicionário
# Essa func só reseta a variável
func gen_dicts_symbols():
	dicts_symbols = {"A1": null, "A2": null, "A3": null,
					"B1": null, "B2": null, "B3": null, 
					"C1": null, "C2": null, "C3": null
					}
	return dicts_symbols


# Escolhe de maneira aleatória qual símbolo do player e do cpu
func randomize_symbols():
	var rng_symbol := rng.randi_range(0,1)
	
	if rng_symbol == 0:
		player_symbol = "Circle"
		cpu_symbol = "Cross"

	else:
		player_symbol = "Cross"
		cpu_symbol = "Circle"
	
	return [player_symbol, cpu_symbol]
	
	
# Informa ao jogador qual seu símbolo nessa partida
func show_symbol_info(player_symbol):
	if player_symbol == "Circle":
		$Your_symbol_is/Symbol.text = "○"
		$Your_symbol_is/Symbol.add_theme_color_override("font_color", Color(0, 188, 255))
		$Player.symbol_attached = "Circle"
		$CPU.symbol_attached = "Cross"
	else:
		$Your_symbol_is/Symbol.text = "X"
		$Your_symbol_is/Symbol.add_theme_color_override("font_color", Color(255, 0, 0))
		$Player.symbol_attached = "Cross"
		$CPU.symbol_attached = "Circle"
	$Your_symbol_is.visible = true


# Inicia ou reinicia uma partida
func prepare_game():
	# Reseta todas as variáveis da partida
	
	control = true
	audios_finished = 0
	game_just_started = true
	winner = null
	winner_symbol = null
	game_ended = false
	turn_counter = 0
	player_turn_order = null
	
	mediate_turns()
	
	$Board.visible = true
	$Whos_turn_is_it.visible = true
	$Your_symbol_is.visible = true
	$Show_winner.visible = false
	$Keybind_info.visible = true
	$Score.visible = true
	
	for button in get_tree().get_nodes_in_group("navigation_buttons"):
		button.queue_free()
		
	for symbol in get_tree().get_nodes_in_group("symbols"):
		symbol.queue_free()
		

	symbols_attached = randomize_symbols()  # De quem é cada símbolo
	show_symbol_info(player_symbol)
	var dicts_symbols = gen_dicts_symbols()

	gen_buttons_symbols(symbols_attached, dicts_symbols)
	
	
# Função que cuida da mecânica de turnos
func mediate_turns():
	if not game_ended:
		for button in get_tree().get_nodes_in_group("navigation_buttons"):
			button.disabled = true
		turn_counter += 1

		# Escolhe de maneira aleatória a ordem de quem joga e faz alternância de turnos
		if player_turn_order == null:  # prepare_game() reseta essa variável
			player_turn_order = rng.randi_range(1,2)  # Jogará primeiro se 1 e jogará em turnos ímpares
			
		if player_turn_order == 1:
			if turn_counter % 2 != 0:  # Se ímpar
				if turn_counter > 1:
					posicionou_na_casa.play()
					await posicionou_na_casa.finished
					for child in $Audio.get_children():
						var child_string := child.name
						if not $CPU.last_slot_used:
							await get_tree().process_frame
						if child_string == $CPU.last_slot_used:
							child.play()
							await child.finished
						
				whos_turn_is_it = $Player
				$Player.player_turns = 1
				$Player.is_player_turn = true
				$CPU.cpu_turns = 2
				$CPU.is_cpu_turn = false
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]Jogador 1[/u]"
				
			else:  # Se par
				if turn_counter > 1:
					posicionou_na_casa.play()
					await posicionou_na_casa.finished
					for child in $Audio.get_children():
						var child_string := child.name
						if not $Player.last_slot_used:
							await get_tree().process_frame
						if child_string == $Player.last_slot_used:
							child.play()
							await child.finished
						
				whos_turn_is_it = $CPU
				$Player.player_turns = 2
				$Player.is_player_turn = false
				$CPU.cpu_turns = 1
				$CPU.is_cpu_turn = true
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]CPU[/u]"
				$CPU.cpu_place_symbol()
		else:  # Se player_turn_order == 2
			if turn_counter % 2 != 0:  # Se ímpar
				if turn_counter > 1:
					posicionou_na_casa.play()
					await posicionou_na_casa.finished
					for child in $Audio.get_children():
						var child_string := child.name
						if not $Player.last_slot_used:
							await get_tree().process_frame
						if child_string == $Player.last_slot_used:
							child.play()
							await child.finished
						
				whos_turn_is_it = $CPU
				$CPU.cpu_turns = 1
				$CPU.is_cpu_turn = true
				$Player.player_turns = 2
				$Player.is_player_turn = false
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]CPU[/u]"
				$CPU.cpu_place_symbol()

			else:  # Se par
				if turn_counter > 1:
					posicionou_na_casa.play()
					await posicionou_na_casa.finished
					for child in $Audio.get_children():
						var child_string := child.name
						if not $CPU.last_slot_used:
							await get_tree().process_frame
						if child_string == $CPU.last_slot_used:
							child.play()
							await child.finished
						
				whos_turn_is_it = $Player
				$CPU.cpu_turns = 2
				$CPU.is_cpu_turn = false
				$Player.player_turns = 1
				$Player.is_player_turn = true
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]Jogador 1[/u]"
		$Whos_turn_is_it.visible = true


# A cada jogada, checa se deu fim de jogo e o vencedor
func check_game_end():
	
	
	if not game_ended:
		if dicts_symbols["A1"] and dicts_symbols["A2"] and dicts_symbols["A3"]:
			if dicts_symbols["A1"] == dicts_symbols["A2"] and dicts_symbols["A2"] == dicts_symbols["A3"]:
				winner_symbol = dicts_symbols["A1"]
				game_ended = true

		if dicts_symbols["A1"] and dicts_symbols["B1"] and dicts_symbols["C1"]:
			if dicts_symbols["A1"] == dicts_symbols["B1"] and dicts_symbols["B1"] == dicts_symbols["C1"]:
				winner_symbol = dicts_symbols["A1"]
				game_ended = true

		if dicts_symbols["A1"] and dicts_symbols["B2"] and dicts_symbols["C3"]:
			if dicts_symbols["A1"] == dicts_symbols["B2"] and dicts_symbols["B2"] == dicts_symbols["C3"]:
				winner_symbol = dicts_symbols["A1"]
				game_ended = true

		if dicts_symbols["A2"] and dicts_symbols["B2"] and dicts_symbols["C2"]:
			if dicts_symbols["A2"] == dicts_symbols["B2"] and dicts_symbols["B2"] == dicts_symbols["C2"]:
				winner_symbol = dicts_symbols["A2"]
				game_ended = true

		if dicts_symbols["A3"] and dicts_symbols["B3"] and dicts_symbols["C3"]:
			if dicts_symbols["A3"] == dicts_symbols["B3"] and dicts_symbols["B3"] == dicts_symbols["C3"]:
				winner_symbol = dicts_symbols["A3"]
				game_ended = true

		if dicts_symbols["A3"] and dicts_symbols["B2"] and dicts_symbols["C1"]:
			if dicts_symbols["A3"] == dicts_symbols["B2"] and dicts_symbols["B2"] == dicts_symbols["C1"]:
				winner_symbol = dicts_symbols["A3"]
				game_ended = true

		if dicts_symbols["B1"] and dicts_symbols["B2"] and dicts_symbols["B3"]:
			if dicts_symbols["B1"] == dicts_symbols["B2"] and dicts_symbols["B2"] == dicts_symbols["B3"]:
				winner_symbol = dicts_symbols["B1"]
				game_ended = true

		if dicts_symbols["C1"] and dicts_symbols["C2"] and dicts_symbols["C3"]:
			if dicts_symbols["C1"] == dicts_symbols["C2"] and dicts_symbols["C2"] == dicts_symbols["C3"]:
				winner_symbol = dicts_symbols["C1"]
				game_ended = true

		if get_tree().get_node_count_in_group("navigation_buttons") == 0:
			game_ended = true

	if game_ended:
		game_end()
		game_end_screen()


# Chama o menu principal
func go_to_menu():
	new_menu = menu_principal.instantiate()
	self.add_child(new_menu)
	$Board.visible = false
	$Whos_turn_is_it.visible = false
	$Your_symbol_is.visible = false
	$Cpu_thinking_message.visible = false
	$Show_winner.visible = false
	$Keybind_info.visible = false
	$Score.visible = false
	$Audio/Menu_principal.play()
	game_restarted = false


# Chamada logo após a última jogada da partida
func game_end_screen():

	$Show_winner.visible = true
	
	if winner is String:
		if winner == "Draw":
			$Show_winner/Winner_name.text = "[center][u]Empate![/u]"
	elif winner == $Player:
		$Show_winner/Winner_name.text = "[center]Vencedor: [u]Jogador 1[/u]"
	elif winner == $CPU:
		$Show_winner/Winner_name.text = "[center]Vencedor: [u]CPU[/u]"


func how_to_play_screen():
	new_how_to_play = como_jogar.instantiate()
	self.add_child(new_how_to_play)


func _on_inicio_partida_finished() -> void:
	if player_symbol == "Circle":
		j1_circle.play()
	else:
		j1_x.play()


func _on_jogador_1_circulo_finished() -> void:
	e_a_vez_do.play()


func _on_jogador_1x_finished() -> void:
	e_a_vez_do.play()


func _on_partida_reiniciada_finished() -> void:
	if player_symbol == "Circle":
		j1_circle.play()
	else:
		j1_x.play()


func _on_e_a_vez_do_finished() -> void:
	if whos_turn_is_it == $Player:
		j1.play()
	elif whos_turn_is_it == $CPU:
		cpu.play()


func _on_jogador_1_finished() -> void:
	if not game_ended:
		for button in get_tree().get_nodes_in_group("navigation_buttons"):
			button.disabled = false


func _on_a_1_finished() -> void:
	after_symbol_placed()


func _on_a_2_finished() -> void:
	after_symbol_placed()


func _on_a_3_finished() -> void:
	after_symbol_placed()


func _on_b_1_finished() -> void:
	after_symbol_placed()


func _on_b_2_finished() -> void:
	after_symbol_placed()


func _on_b_3_finished() -> void:
	after_symbol_placed()


func _on_c_1_finished() -> void:
	after_symbol_placed()


func _on_c_2_finished() -> void:
	after_symbol_placed()


func _on_c_3_finished() -> void:
	after_symbol_placed()


func after_symbol_placed():
	if not game_ended:
		e_a_vez_do.play()
		await e_a_vez_do.finished


func game_end():
	if winner_symbol == player_symbol:
		winner = $Player
		$Player.score += 1
		$Score/Score_1/Score_1.text = str($Player.score)
	elif winner_symbol == cpu_symbol:
		winner = $CPU
		$CPU.score += 1
		$Score/Score_CPU/Score_CPU.text = str($CPU.score)
	else:
		winner = "Draw"
	
	fim_de_partida.play()
	await fim_de_partida.finished
	
	vencedor_e.play()
	await vencedor_e.finished
	
	if winner is String:
		if winner == "Draw":
			empate.play()
			await empate.finished
			
	elif winner == $Player:
		j1.play()
		await j1.finished
		
	elif winner == $CPU:
		cpu.play()
		await cpu.finished
	
