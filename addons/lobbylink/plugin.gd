@tool
extends EditorPlugin

func _enter_tree():
	# AutoLoad-Singleton registrieren (nur beim Aktivieren des Plugins)
	add_autoload_singleton("LobbyLink", "res://addons/lobbylink/scripts/LobbyLink.gd")
	add_autoload_singleton("LobbyLink_WebRTCConnection", "res://addons/lobbylink/scripts/LobbyLink_WebRTCConnection.gd")
	add_autoload_singleton("LobbyLink_WebSocketConnection", "res://addons/lobbylink/scripts/LobbyLink_WebSocketConnection.gd")
	add_autoload_singleton("LobbyLink_WebSocketMessage", "res://addons/lobbylink/scripts/LobbyLink_WebSocketMessage.gd")
	add_autoload_singleton("LobbyLink_ConfigHandler", "res://addons/lobbylink/scripts/LobbyLink_ConfigHandler.gd")

func _exit_tree():
	# AutoLoad wieder entfernen beim Deaktivieren des Plugins
	remove_autoload_singleton("LobbyLink")
	remove_autoload_singleton("LobbyLink_WebRTCConnection")
	remove_autoload_singleton("LobbyLink_WebSocketConnection")
	remove_autoload_singleton("LobbyLink_WebSocketMessage")
	remove_autoload_singleton("LobbyLink_ConfigHandler")
