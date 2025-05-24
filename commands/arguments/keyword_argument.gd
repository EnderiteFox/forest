class_name KeywordArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.KEYWORD
	
	
func accepts_token(_token: String) -> bool:
	return true
	
	
func parse_token(token: String) -> String:
	return token
