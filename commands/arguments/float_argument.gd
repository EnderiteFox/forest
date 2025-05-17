class_name FloatArgument
extends CommandTreeArgument


func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.FLOAT
	
	
func accepts_token(token: String) -> bool:
	return token.is_valid_float()
	
	
func parse_token(token: String) -> float:
	return token.to_float()
