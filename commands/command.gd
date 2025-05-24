class_name Command
extends CommandTreeNode

@export var command_name: String

@export var command_callbacks: Dictionary[Array, CustomCallback] = {}


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.KEYWORD
	

func accepts_token(token: String) -> bool:
	return token == command_name
