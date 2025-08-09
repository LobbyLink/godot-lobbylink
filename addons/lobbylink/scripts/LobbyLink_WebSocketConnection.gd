extends Node

signal connected_to_server()
signal connection_closed()

var socket: WebSocketPeer = WebSocketPeer.new()
var started_connection: bool = false
var last_state = WebSocketPeer.STATE_CLOSED

func _ready():
	socket.set_supported_protocols(PackedStringArray(["lobbylink"]))
	connected_to_server.connect(_on_connected_to_server)
	pass 

func _process(_delta):
	# Don't start polling if connectipon is not initialized yet
	if started_connection:
		_poll_connection()
	pass

func _poll_connection():
	# Poll connection
	socket.poll()
	var state = socket.get_ready_state()
	_check_state_change(state)
	
	# Handle WebSocket connection based on the current state
	match state:
		# When connected read all new messages.
		WebSocketPeer.STATE_OPEN:
			_read_new_packages()
		
		# Keep polling to achieve proper close.
		WebSocketPeer.STATE_CLOSING:
			return
		
		# Stop processing when connection is closed.
		WebSocketPeer.STATE_CLOSED:
			_connection_closed()
	pass

func connect_to_signaling_server():
	started_connection = true
	print("Starting connection to SignalingServer: %s." % [LobbyLink_ConfigHandler.WS])
	var err = socket.connect_to_url(LobbyLink_ConfigHandler.WS)
	if err: print("Error connecting to SignalingServer: %s." % [err])
	pass

func _check_state_change(state):
	# Check if the State changed and initial connection happened
	if last_state == WebSocketPeer.STATE_CLOSED && state == WebSocketPeer.STATE_OPEN: 
		connected_to_server.emit()
		last_state = state
	pass

func _read_new_packages():
	while socket.get_available_packet_count():
		var payload_string = socket.get_packet().get_string_from_utf8()
		LobbyLink_WebSocketMessage.handle_message(payload_string)
	pass

func _connection_closed():
	var code = socket.get_close_code()
	var reason = socket.get_close_reason()
	print("WebSocket closed with code: %d, reason %s. Clean: %s." % [code, reason, code != -1])
	connection_closed.emit()
	set_process(false) 
	pass

func _on_connected_to_server():
	print("Successfully connected to SignalingServer: %s." % [LobbyLink_ConfigHandler.WS])
	if LobbyLink.get_is_server():
		LobbyLink_WebSocketMessage.msg_req_room_code()
	else:
		LobbyLink_WebSocketMessage.msg_req_id()
	pass
