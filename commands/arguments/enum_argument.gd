class_name EnumArgument
extends CommandTreeArgument

@export var possible_values: Array[String]


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.KEYWORD
	
	
func accepts_token(token: String) -> bool:
	return token in possible_values
	
	
func parse_token(token: String) -> String:
	return token
