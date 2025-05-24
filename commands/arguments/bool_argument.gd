class_name BoolArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.BOOL
	

func accepts_token(_token: String) -> bool:
	return true
	
	
func parse_token(token: String) -> bool:
	if token in ['true', '1b']:
		return true
	return false
