extends Control

onready var scroll_container = get_node("ScrollContainer")
onready var vertical_container = scroll_container.get_node("VBoxContainer")

var current_index = 0
var pokemon_id = 0

signal send_request_pokemon

var initial_offset = 0
var index = 0

var target_scroll_value = 396
var key = false
var animation_key = false

func _ready():
	request_pokemon_list_size(initial_offset)
	
func request_pokemon_list_size(offset):
	var pokemon_total_list_url = HTTPRequest.new()
	add_child(pokemon_total_list_url)
	pokemon_total_list_url.set_use_threads(true)
	pokemon_total_list_url.connect("request_completed", self, "_get_pokemon_list_size")
	pokemon_total_list_url.request("https://pokeapi.co/api/v2/pokemon?limit=0&offset=" + str(offset)) 
	
	
func _get_pokemon_list_size(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var pokemon_list_size = json.result.results.size()
	for i in pokemon_list_size:
		index += 1
		instance_objects()
		var pokemon_name = json.result.results[i].name
		var pokemon_request = HTTPRequest.new()
		var pokemon_image = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + str(index) + ".png"
		add_child(pokemon_request)
		pokemon_request.set_use_threads(true)
		pokemon_request.connect("request_completed", self, "_get_current_pokemon")
		pokemon_request.request(pokemon_image)
		yield(pokemon_request, "request_completed")
		
		set_pokemon_id(index)
		vertical_container.get_child(current_index - 1).get_child(2).text = pokemon_name.to_upper()
			
	key = true
		
		
func instance_objects():
	var horizontal_container = HBoxContainer.new()
	vertical_container.add_child(horizontal_container)
	horizontal_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var texture_rect = TextureRect.new()
	horizontal_container.add_child(texture_rect)
	var label = Label.new()
	horizontal_container.add_child(label)
	var button = Button.new()
	horizontal_container.add_child(button)
	button.flat = true
	button.enabled_focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.connect("pressed", self, "get_pokemon_info", [button])
	
	
func set_pokemon_id(id):
	if id < 10:
		vertical_container.get_child(current_index - 1).get_child(1).text = "#00" + str(id) 
	elif id >= 10 and id < 100:
		vertical_container.get_child(current_index - 1).get_child(1).text = "#0" + str(id) 
	else:
		vertical_container.get_child(current_index - 1).get_child(1).text = "#" + str(id)
	
	
func get_pokemon_info(pokemon_name):
	scroll_container.hide()
	get_node("Button").hide()
	var pokemon_url = "https://pokeapi.co/api/v2/pokemon/" + pokemon_name.text.to_lower()
	emit_signal("send_request_pokemon", pokemon_url)
	
	
func _get_current_pokemon(_result, _response_code, _headers, body):
	current_index += 1
	var image = Image.new()
	image.load_png_from_buffer(body)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.set_size_override(Vector2(32, 32))
	vertical_container.get_child(current_index - 1).get_child(0).texture = texture


func _process(_delta):
	if (scroll_container.scroll_vertical == target_scroll_value) and key:
		initial_offset += 20
		target_scroll_value += 720
		request_pokemon_list_size(initial_offset)
		key = false


func _on_BackButton_pressed():
	get_node("Container").hide()
	get_node("Button").show()
	scroll_container.show()


func _on_SearchBar_Button_pressed():
	if animation_key == false:
		get_node("Animation").play("ShowSearchBar")
		animation_key = true
	else:
		get_node("Animation").play("HideSearchBar")
		animation_key = false
