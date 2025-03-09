extends Node2D

@onready var audio_player = $AudioStreamPlayer



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_toggled(toggled_on):
	if toggled_on:
		$BasicBarsExample.visible = false
		$CircularExample.visible = true
	else:
		$BasicBarsExample.visible = true
		$CircularExample.visible = false


func _on_play_pressed():
	if audio_player:
		audio_player.play()
