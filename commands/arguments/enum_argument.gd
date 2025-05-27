class_name EnumArgument
extends CommandTreeArgument

@export var possible_values: Array[String]


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.KEYWORD
	
	
func accepts_token(token: String) -> bool:
	return token in possible_values
	
	
func parse_token(token: String) -> String:
	return token
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	return possible_values.filter(
		func(enum_val: String): return enum_val.begins_with(partial_token)
	)
