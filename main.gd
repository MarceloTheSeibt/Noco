extends Node

@export var menu_principal: PackedScene

const circle = preload("res://circle.tscn")
const cross = preload("res://x.tscn")
const icon = preload("res://vecteezy_geometric-design-element_21048718.png")
var turn_counter = 0
var whos_turn_is_it = null  # De quem é a vez de jogar atualmente
var player_turn_order = null  # Se o jogador terá turnos ímpares ou pares
var player_symbol = null 
var cpu_symbol = null
var symbols_attached = null  # [0] = player [1] = CPU
var rng = RandomNumberGenerator.new()
var dicts_symbols = {"A1": null, "A2": null, "A3": null,
					"B1": null, "B2": null, "B3": null, 
					"C1": null, "C2": null, "C3": null
					}
var game_ended = false
var winner = null
var winner_symbol = null
var new_menu

# Buttons
var offset_button_x := 30
var offset_button_y := 75
var button_symbol_scale := Vector2(1,1)
#---------------------------------------#


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	go_to_menu()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart_game"):  # Reinicia a partida "R"
		if not new_menu:
			prepare_game()
			print("Partida Reiniciada")
	elif Input.is_action_just_pressed("main_menu"):
		if not new_menu:
			go_to_menu()
	#print(dicts_symbols)


func _button_symbol_pressed(slot, current_player_symbol):

	if current_player_symbol == "Circle":
		var new_circle = circle.instantiate()
		new_circle.set_global_position(slot.get_parent().get_parent().global_position)
		self.add_child(new_circle)
		new_circle.add_to_group("symbols")
	else:
		var new_cross = cross.instantiate()
		new_cross.set_global_position(slot.get_parent().get_parent().global_position)
		self.add_child(new_cross)
		new_cross.add_to_group("symbols")
	
	var slot_used_string = slot.get_parent().get_parent().to_string().left(2)
	dicts_symbols[slot_used_string] = current_player_symbol  # Key recebe o value do símbolo posicionado
	
	var button = slot  # Variável para função rearrange_menu
	var button_parent = slot.get_parent()
	
	slot.queue_free()
	#var c = 0  # Debug
	# Aguarda a deleção do objeto para rodar a função rearrange_menu
	while slot != null:
		await get_tree().process_frame
		#c += 1  # Debug
		#print(c)  # Debug
	check_game_end()
	rearrange_menu(button, button_parent)
	mediate_turns()
	#print("player= ", player_symbol)  # Debug
	#print("cpu= ", cpu_symbol)  # Debug


# Gera os botões que permitem posicionar os símbolos
func gen_buttons_symbols(symbols_attached, dicts_symbols):
	var button_symbol_text := ""
	if symbols_attached[0] == "Circle":
		button_symbol_text = "Posicionar ○ aqui"
	else:
		button_symbol_text = "Posicionar X aqui"
	
	var button_a1 = Button.new()
	button_a1.text = button_symbol_text
	button_a1.scale = button_symbol_scale
	$Board/HitboxesA/A1/A1.add_child(button_a1)
	button_a1.position = button_a1.position - button_a1.size / 2
	button_a1.position.x = button_a1.position.x + offset_button_x
	button_a1.position.y = button_a1.position.y + offset_button_y
	button_a1.pressed.connect(_button_symbol_pressed.bind(button_a1, symbols_attached[0]))

	var button_a2 = Button.new()
	button_a2.text = button_symbol_text
	button_a2.scale = button_symbol_scale
	$Board/HitboxesA/A2/A2.add_child(button_a2)
	button_a2.position = button_a2.position - button_a2.size / 2
	button_a2.position.x = button_a2.position.x + offset_button_x
	button_a2.position.y = button_a2.position.y + offset_button_y
	button_a2.pressed.connect(_button_symbol_pressed.bind(button_a2, symbols_attached[0]))
	
	var button_a3 = Button.new()
	button_a3.text = button_symbol_text
	button_a3.scale = button_symbol_scale
	$Board/HitboxesA/A3/A3.add_child(button_a3)
	button_a3.position = button_a3.position - button_a3.size / 2
	button_a3.position.x = button_a3.position.x + offset_button_x
	button_a3.position.y = button_a3.position.y + offset_button_y
	button_a3.pressed.connect(_button_symbol_pressed.bind(button_a3, symbols_attached[0]))

	var button_b1 = Button.new()
	button_b1.text = button_symbol_text
	button_b1.scale = button_symbol_scale
	$Board/HitboxesB/B1/B1.add_child(button_b1)
	button_b1.position = button_b1.position - button_b1.size / 2
	button_b1.position.x = button_b1.position.x + offset_button_x
	button_b1.position.y = button_b1.position.y + offset_button_y
	button_b1.pressed.connect(_button_symbol_pressed.bind(button_b1, symbols_attached[0]))
	
	var button_b2 = Button.new()
	button_b2.text = button_symbol_text
	button_b2.scale = button_symbol_scale
	$Board/HitboxesB/B2/B2.add_child(button_b2)
	button_b2.position = button_b2.position - button_b2.size / 2
	button_b2.position.x = button_b2.position.x + offset_button_x
	button_b2.position.y = button_b2.position.y + offset_button_y
	button_b2.pressed.connect(_button_symbol_pressed.bind(button_b2, symbols_attached[0]))

	var button_b3 = Button.new()
	button_b3.text = button_symbol_text
	button_b3.scale = button_symbol_scale
	$Board/HitboxesB/B3/B3.add_child(button_b3)
	button_b3.position = button_b3.position - button_b3.size / 2
	button_b3.position.x = button_b3.position.x + offset_button_x
	button_b3.position.y = button_b3.position.y + offset_button_y
	button_b3.pressed.connect(_button_symbol_pressed.bind(button_b3, symbols_attached[0]))
	
	var button_c1 = Button.new()
	button_c1.text = button_symbol_text
	button_c1.scale = button_symbol_scale
	$Board/HitboxesC/C1/C1.add_child(button_c1)
	button_c1.position = button_c1.position - button_c1.size / 2
	button_c1.position.x = button_c1.position.x + offset_button_x
	button_c1.position.y = button_c1.position.y + offset_button_y
	button_c1.pressed.connect(_button_symbol_pressed.bind(button_c1, symbols_attached[0]))
	
	var button_c2 = Button.new()
	button_c2.text = button_symbol_text
	button_c2.scale = button_symbol_scale
	$Board/HitboxesC/C2/C2.add_child(button_c2)
	button_c2.position = button_c2.position - button_c2.size / 2
	button_c2.position.x = button_c2.position.x + offset_button_x
	button_c2.position.y = button_c2.position.y + offset_button_y
	button_c2.pressed.connect(_button_symbol_pressed.bind(button_c2, symbols_attached[0]))
	
	var button_c3 = Button.new()
	button_c3.text = button_symbol_text
	button_c3.scale = button_symbol_scale
	$Board/HitboxesC/C3/C3.add_child(button_c3)
	button_c3.position = button_c3.position - button_c3.size / 2
	button_c3.position.x = button_c3.position.x + offset_button_x
	button_c3.position.y = button_c3.position.y + offset_button_y
	button_c3.pressed.connect(_button_symbol_pressed.bind(button_c3, symbols_attached[0]))

	# Botões ficarão no grupo para melhor organização
	button_a1.add_to_group("navigation_buttons")
	button_a1.add_to_group("navigation_buttons_a")
	button_a2.add_to_group("navigation_buttons")
	button_a2.add_to_group("navigation_buttons_a")
	button_a3.add_to_group("navigation_buttons")
	button_a3.add_to_group("navigation_buttons_a")
	button_b1.add_to_group("navigation_buttons")
	button_b1.add_to_group("navigation_buttons_b")
	button_b2.add_to_group("navigation_buttons")
	button_b2.add_to_group("navigation_buttons_b")
	button_b3.add_to_group("navigation_buttons")
	button_b3.add_to_group("navigation_buttons_b")
	button_c1.add_to_group("navigation_buttons")
	button_c1.add_to_group("navigation_buttons_c")
	button_c2.add_to_group("navigation_buttons")
	button_c2.add_to_group("navigation_buttons_c")
	button_c3.add_to_group("navigation_buttons")
	button_c3.add_to_group("navigation_buttons_c")


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


func rearrange_menu(button_deleted, button_parent):
	if get_tree().get_node_count_in_group("navigation_buttons") > 0:
		var button_0 = get_tree().get_nodes_in_group("navigation_buttons")[0]
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
	var rng_symbol = rng.randi_range(0,1)
	
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
		$Player.symbol_attached = "Circle"
		$CPU.symbol_attached = "Cross"
	else:
		$Your_symbol_is/Symbol.text = "X"
		$Player.symbol_attached = "Cross"
		$CPU.symbol_attached = "Circle"
	$Your_symbol_is.visible = true


# Inicia ou reinicia uma partida
func prepare_game():
	# Reseta todas as variáveis da partida
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
	
	for button in get_tree().get_nodes_in_group("navigation_buttons"):
		button.queue_free()
		
	for symbol in get_tree().get_nodes_in_group("symbols"):
		symbol.queue_free()
		

	symbols_attached = randomize_symbols()  # De quem é cada símbolo
	var dicts_symbols = gen_dicts_symbols()
	show_symbol_info(player_symbol)
	#print(player_symbol)  # Debug
	gen_buttons_symbols(symbols_attached, dicts_symbols)
	
	
# Função que cuida da mecânica de turnos
func mediate_turns():
	if not game_ended:
		turn_counter += 1
		#print(turn_counter, "turn_counter")
		# Escolhe de maneira aleatória a ordem de quem joga e faz alternância de turnos
		if player_turn_order == null:  # prepare_game() reseta essa variável
			player_turn_order = rng.randi_range(1,2)  # Jogará primeiro se 1 e jogará em turnos ímpares
			#player_turn_order = 2 # DEBUG, REMOVER
		if player_turn_order == 1:
			if turn_counter % 2 != 0:  # Se ímpar
				whos_turn_is_it = $Player
				$Player.player_turns = 1
				$Player.is_player_turn = true
				$CPU.cpu_turns = 2
				$CPU.is_cpu_turn = false
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]Jogador 1[/u]"
			else:  # Se par
				whos_turn_is_it = $CPU
				$Player.player_turns = 2
				$Player.is_player_turn = false
				$CPU.cpu_turns = 1
				$CPU.is_cpu_turn = true
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]CPU[/u]"
				$CPU.cpu_place_symbol()
		else:  # Se player_turn_order == 2
			if turn_counter % 2 != 0:  # Se ímpar
				whos_turn_is_it = $CPU
				$CPU.cpu_turns = 1
				$CPU.is_cpu_turn = true
				$Player.player_turns = 2
				$Player.is_player_turn = false
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]CPU[/u]"
				$CPU.cpu_place_symbol()

			else:  # Se par
				whos_turn_is_it = $Player
				$CPU.cpu_turns = 2
				$CPU.is_cpu_turn = false
				$Player.player_turns = 1
				$Player.is_player_turn = true
				$Whos_turn_is_it/Player_or_CPU.text = "[center][u]Jogador 1[/u]"
		#print("turn_order= ",player_turn_order)
		$Whos_turn_is_it.visible = true
	else:
		game_end_screen()
		print("Acabou a partida")

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
			winner_symbol = "Draw"  # Em caso de empate
	if game_ended:
		if winner_symbol == player_symbol:
			winner = $Player
			$Player.score += 1
		elif winner_symbol != player_symbol:
			winner = $CPU
			$CPU.score += 1
		else:
			winner = "Draw"
		print("Vencedor: ", winner)


func go_to_menu():
	new_menu = menu_principal.instantiate()
	self.add_child(new_menu)
	$Board.visible = false
	$Whos_turn_is_it.visible = false
	$Your_symbol_is.visible = false
	$Cpu_thinking_message.visible = false
	$Show_winner.visible = false


# Chamada logo após a última jogada da partida
func game_end_screen():
	if get_tree().get_node_count_in_group("navigation_buttons") > 0:
		for button in get_tree().get_nodes_in_group("navigation_buttons"):
			button.disabled = true

	$Show_winner.visible = true
	if winner == $Player:
		$Show_winner/Winner_name.text = "[center]Vencedor: [u]Jogador 1[/u]"
	elif winner == $CPU:
		$Show_winner/Winner_name.text = "[center]Vencedor: [u]CPU[/u]"
	elif winner == "Draw":
		$Show_winner/Winner_name.text = "[center][u]Empate![/u]"
	
