extends Control

onready var vertical_container = get_node("ScrollContainer/VBoxContainer")

var current_index = 0
var pokemon_id = 0

func _ready():
	request_pokemon_list_size()
	
func request_pokemon_list_size():
	var pokemon_total_list_url = HTTPRequest.new()
	add_child(pokemon_total_list_url)
	pokemon_total_list_url.set_use_threads(true)
	pokemon_total_list_url.connect("request_completed", self, "_get_pokemon_list_size")
	pokemon_total_list_url.request("https://pokeapi.co/api/v2/pokemon?limit=20&offset=0") 
	
	
func _get_pokemon_list_size(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var pokemon_list_size = json.result.results.size()
	for i in pokemon_list_size:
		instance_objects()
		var pokemon_name = json.result.results[i].name
		var pokemon_request = HTTPRequest.new()
		var pokemon_image = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + str(i + 1) + ".png"
		add_child(pokemon_request)
		pokemon_request.set_use_threads(true)
		pokemon_request.connect("request_completed", self, "_get_current_pokemon")
		pokemon_request.request(pokemon_image)
		yield(pokemon_request, "request_completed")
		vertical_container.get_child(current_index - 1).get_child(1).text = "Id: " + str(i + 1) + " Nome: " + pokemon_name
		
		
func instance_objects():
	var horizontal_container = HBoxContainer.new()
	vertical_container.add_child(horizontal_container)
	var texture_rect = TextureRect.new()
	horizontal_container.add_child(texture_rect)
	var label = Label.new()
	horizontal_container.add_child(label)
	
	
func _get_current_pokemon(_result, _response_code, _headers, body):
	current_index += 1
	var image = Image.new()
	image.load_png_from_buffer(body)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.set_size_override(Vector2(32, 32))
	vertical_container.get_child(current_index - 1).get_child(0).texture = texture
