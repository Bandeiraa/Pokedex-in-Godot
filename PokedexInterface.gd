extends Control

onready var vertical_container = get_node("ScrollContainer/VBoxContainer")

var current_index = 0
var pokemon_id = 0

func _ready():
	request_pokemon_list_size()
	
func request_pokemon_list_size():
	var pokemon_total_list_url = HTTPRequest.new()
	add_child(pokemon_total_list_url)
	pokemon_total_list_url.connect("request_completed", self, "_get_pokemon_list_size")
	pokemon_total_list_url.request("https://pokeapi.co/api/v2/pokemon?limit=898&offset=0") 
	
func _get_pokemon_list_size(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var pokemon_list_size = json.result.results.size()
	for i in pokemon_list_size:
		var label = Label.new()
		vertical_container.add_child(label)
		
	_request_current_pokemon_list()
	
func _request_current_pokemon_list():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_get_current_pokemon_list")
	http_request.request("https://pokeapi.co/api/v2/pokemon?limit=20&offset=0")
	
func _get_current_pokemon_list(_result, _responde_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for pokemon_name in json.result.results:
		get_current_pokemon(pokemon_name.name)

func get_current_pokemon(poke_name):
	pokemon_id += 1
	current_index += 1
	vertical_container.get_child(current_index - 1).text = "Id: " + str(pokemon_id) + " Nome: " + poke_name
