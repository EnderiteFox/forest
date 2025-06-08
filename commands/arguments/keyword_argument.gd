class_name KeywordArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.KEYWORD
	
	
func accepts_token(token: String) -> bool:
	return token == self.argument_name
	
	
func parse_token(token: String) -> String:
	return token
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	if self.argument_name.begins_with(partial_token):
		return [self.argument_name]
	else:
		return []
