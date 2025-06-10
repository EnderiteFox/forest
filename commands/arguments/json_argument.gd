class_name JsonArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.JSON
	
	
func accepts_token(_token: String, _preparse_mode: bool = false) -> bool:
	# Json tokens are assumed to be valid Json objects
	return true
	
	
func parse_token(token: String) -> Variant:
	return JSON.parse_string(token)
