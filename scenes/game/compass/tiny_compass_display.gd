extends Control

var dir: String
var color: Color
var player_id: int

func _update_display():
	#Turn off everything
	#Cardinal
	$North.visible = false
	$East.visible = false
	$South.visible = false
	$West.visible = false
	#Intercardinal
	$Northeast.visible = false
	$Southeast.visible = false
	$Southwest.visible = false
	$Northwest.visible = false
	
	$None.visible = false
	
	#Turn on the one we match
	match dir:
		"North":
			$North.visible = false
		"East":
			$East.visible = false
		"South":
			$South.visible = false
		"West":
			$West.visible = false
		"Northeast":
			$Northeast.visible = false
		"Southeast":
			$Southeast.visible = false
		"Southwest":
			$Southwest.visible = false
		"Northwest":
			$Northwest.visible = false
		_:
			$None.visible = true
