extends Node2D

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	get_viewport().size_changed.connect(resize)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func resize():  # Redimensiona e reposiciona o board ao redimensionar tela
	position = screen_size / 2
