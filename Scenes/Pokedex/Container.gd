extends Control

func _send_request_pokemon(pokemon_url):
	var pokemon_request = HTTPRequest.new()
	add_child(pokemon_request)
	pokemon_request.set_use_threads(true)
	pokemon_request.connect("request_completed", self, "_get_requested_pokemon_data")
	pokemon_request.request(pokemon_url) 
	
	
func _get_requested_pokemon_data(_result, _response_code, _headers, body):
	var json_format_data = JSON.parse(body.get_string_from_utf8())
	var pokemon_sprite = json_format_data.result.sprites.front_default
	
	get_node("InitialInfoContainer/PokemonName").text = json_format_data.result.name.to_upper()
	set_pokemon_id(json_format_data.result.id)
	set_pokemon_abilities(json_format_data.result.abilities)
	set_pokemon_height(json_format_data.result.height)
	set_pokemon_weight(json_format_data.result.weight)
	
	#Image request
	var pokemon_image_request = HTTPRequest.new()
	add_child(pokemon_image_request)
	pokemon_image_request.set_use_threads(true)
	pokemon_image_request.connect("request_completed", self, "_get_requested_pokemon_image")
	pokemon_image_request.request(pokemon_sprite)
	
	
func set_pokemon_id(id):
	if id < 10:
		get_node("InitialInfoContainer/PokemonId").text = "#00" + str(id)
	elif id >= 10 and id < 100:
		get_node("InitialInfoContainer/PokemonId").text = "#0" + str(id)
	else:
		get_node("InitialInfoContainer/PokemonId").text = "#" + str(id)
		
		
func set_pokemon_abilities(abilities):
	if abilities.size() > 1:
		get_node("AbilitiesContainer/Ability1").text = abilities[0].ability.name + ", "
		get_node("AbilitiesContainer/Ability2").text = abilities[1].ability.name
	else:
		get_node("AbilitiesContainer/Ability1").text = abilities[0].ability.name
		get_node("AbilitiesContainer/Ability2").text = ""
		
		
func set_pokemon_height(height):
	if height < 10:
		get_node("HeightContainer/PokemonHeight").text = "0." + str(height) + " m"
	else:
		get_node("HeightContainer/PokemonHeight").text = str(height/10) + " m"
		
		
func set_pokemon_weight(weight):
	get_node("WeightContainer/PokemonWeight").text = str(weight/10) + " kg"
	
	
func _get_requested_pokemon_image(_result, _response_code, _headers, pokemon_image):
	var image = Image.new()
	image.load_png_from_buffer(pokemon_image)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	get_node("PokemonImage").texture = texture
	self.show()
