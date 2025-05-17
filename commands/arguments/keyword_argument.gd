class_name KeywordArgument
extends CommandTreeArgument


func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.KEYWORD
	
	
func accepts_token(_token: String) -> bool:
	return true
	
	
func parse_token(token: String) -> String:
	return token
