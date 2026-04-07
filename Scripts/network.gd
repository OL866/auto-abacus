extends Node

@export var url = "http://10.42.0.2/update"

func send_data(data):
	var dict = {}
	for i in range(len(data)):
		dict[i] = data[i]
	var json = JSON.stringify(dict)
	var error = $HTTPRequest.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json)
	if error != OK:
		print("Something went wrong with the HTTP req")
	await $HTTPRequest.request_completed
	print("Sent ", json)
