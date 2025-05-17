class_name BoolArgument
extends CommandTreeArgument


func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.BOOL
	

func accepts_token(_token: String) -> bool:
	return true
	
	
func parse_token(token: String) -> bool:
	if token in ['true', '1b']:
		return true
	return false
