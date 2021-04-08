extends Control

func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	http_request.request("https://pokeapi.co/api/v2/pokemon/ditto")
	
func _http_request_completed(_result, _responde_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for ability in json.result.abilities:
		print("Ability name: ", ability.ability.name)
