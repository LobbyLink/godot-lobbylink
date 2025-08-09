extends Node

var WS: String
var STUN_IP: String
var STUN_PORT: String
var TURN_IP: String
var TURN_PORT: String
var TURN_USERNAME: String
var TURN_CREDENTIAL: String

func _init():
	var config = ConfigFile.new()
	var err = config.load("res://addons/lobbylink/config.cfg")
	if err != OK:
		push_error("LobbyLink-Konfigurationsdatei konnte nicht geladen werden.")
	
	var ws_ip = config.get_value("websocket", "ip", "")
	var ws_port = config.get_value("websocket", "port", 0)
	WS = "ws://%s:%s" % [ws_ip, ws_port]
	
	STUN_IP = config.get_value("stun", "ip", "")
	STUN_PORT = config.get_value("stun", "port", 0)
	TURN_IP = config.get_value("turn", "ip", "")
	TURN_PORT = config.get_value("turn", "port", 0)
	TURN_USERNAME = config.get_value("turn", "username", "")
	TURN_CREDENTIAL = config.get_value("turn", "credential", "")
