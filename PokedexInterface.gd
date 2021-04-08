extends Control

onready var vertical_container = get_node("VBoxContainer")

func _ready():
	for i in 808:
		var label = Label.new()
		vertical_container.add_child(label)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_request_pokemon_list")
	http_request.request("https://pokeapi.co/api/v2/pokemon?limit=19&offset=0")
	
func _request_pokemon_list(_result, _responde_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for pokemon_url in json.result.results:
		send_pokemon_url(pokemon_url.url)

func send_pokemon_url(poke_url):
	var pokemon_http_request = HTTPRequest.new()
	add_child(pokemon_http_request)
	pokemon_http_request.connect("request_completed", self, "_request_pokemon")
	pokemon_http_request.request(poke_url)
	
func _request_pokemon(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var pokemon_name = json.result.name
	var pokemon_index = json.result.id
	pokemon_info_list(pokemon_name, pokemon_index)

func pokemon_info_list(pkmn_name, pkmn_id):
	for children in vertical_container.get_children().size():
		if children + 1 == pkmn_id:
			vertical_container.get_child(children).text = "Nome: " + pkmn_name + " Id: " + str(pkmn_id)
