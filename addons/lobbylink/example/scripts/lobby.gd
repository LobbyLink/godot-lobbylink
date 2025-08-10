extends Control

func _ready() -> void:
	pass

func _on_client_button_pressed() -> void:
	# Call the init_client(room_code) method to receive a ID. 
	# Disable all other input or change Scene.
	var room_code = $Container/RoomCodeInput.text
	if len(room_code) != 4: return
	LobbyLink.init_client(room_code)
	_disable_input() # Alternatively Change Scene
	pass 

func _on_server_button_pressed() -> void:
	# Call the init_server() Method to receive a Room Code.
	# Disable all other input or change Scene.
	LobbyLink.init_server()
	_disable_input() # Alternatively Change Scene
	pass

func _disable_input():
	$Container/ClientButton.disabled = true
	$Container/ServerButton.disabled = true
	$Container/RoomCodeInput.editable = false
	pass
