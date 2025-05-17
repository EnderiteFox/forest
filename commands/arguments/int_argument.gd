class_name IntArgument
extends CommandTreeArgument

func get_token_type() -> CommandParser.ArgumentType:
	return CommandParser.ArgumentType.INT
	

func accepts_token(token: String) -> bool:
	return token.is_valid_int()
	

func parse_token(token: String) -> int:
	return token.to_int()
