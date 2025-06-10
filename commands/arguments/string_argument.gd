class_name StringArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.STRING
	
	
func accepts_token(_token: String, _preparse_mode: bool = false) -> bool:
	return true
	
	
func parse_token(token: String) -> String:
	return token
