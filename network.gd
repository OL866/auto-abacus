extends Node

@export var url = "https://"
func send_data(data):
	var json = JSON.stringify(data)
	print(json)
	$HTTPRequest.request(url, [""], HTTPClient.METHOD_POST, json)
