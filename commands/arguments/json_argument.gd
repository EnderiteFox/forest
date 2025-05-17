class_name JsonArgument
extends CommandTreeArgument


func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.JSON
	
	
func accepts_token(_token: String) -> bool:
	# Json tokens are assumed to be valid Json objects
	return true
	
	
func parse_token(token: String) -> Variant:
	return JSON.parse_string(token)
