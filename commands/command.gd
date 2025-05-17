class_name Command
extends CommandTreeNode

@export var command_name: String

func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.KEYWORD
	

func accepts_token(token: String) -> bool:
	return token == command_name
