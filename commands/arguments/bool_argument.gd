class_name BoolArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.BOOL
	

func accepts_token(_token: String, _preparse_mode: bool = false) -> bool:
	return true
	
	
func parse_token(token: String) -> bool:
	if token in ['true', '1b']:
		return true
	return false
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	var possible_suggestions: Array[String] = ["true", "false", "1b", "0b"]
	return possible_suggestions.filter(func(elm: String): return elm.begins_with(partial_token))
