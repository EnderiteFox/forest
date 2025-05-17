class_name EnumArgument
extends CommandTreeArgument

@export var possible_values: Array[String]

func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.KEYWORD
	
	
func accepts_token(token: String) -> bool:
	return token in possible_values
	
	
func parse_token(token: String) -> String:
	return token
