extends Label

var player_coins: Dictionary = {}

func _ready() -> void:
	MultiplayerManager.stable_player_data_updated.connect(update_coin_count)
	for player in MultiplayerManager.stable_player_data:
		update_coin_count(player)
	update_display()

func update_coin_count(player, new_data = "coins"):
	if new_data != "coins" or !MultiplayerManager.stable_player_data[player].has("coins"):
		return
	player_coins[player] = MultiplayerManager.stable_player_data[player]["coins"]
	update_display()

func update_display():
	var coin_text: String = ""
	for player in player_coins:
		coin_text += "%s has %d coins.\n" % [MultiplayerManager.stable_player_data[player]["name"], player_coins[player]]
	text = coin_text
