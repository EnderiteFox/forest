class_name Command
extends CommandTreeNode

@export var command_name: String

@export var command_callbacks: Dictionary[Array, CustomCallback] = {}


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.KEYWORD
	

func accepts_token(token: String, preparse_mode: bool = false) -> bool:
	if preparse_mode:
		return command_name.begins_with(token)
	return token == command_name
	
	
func get_autocomplete_suggestions(partial_token: String) -> Array[String]:
	var suggestions: Array[String] = []
	if command_name.begins_with(partial_token):
		suggestions.append(command_name)
	return suggestions
