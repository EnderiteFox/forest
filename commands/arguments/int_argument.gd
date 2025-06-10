class_name IntArgument
extends CommandTreeArgument


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.INT
	

func accepts_token(token: String, _preparse_mode: bool = false) -> bool:
	return token.is_valid_int()
	

func parse_token(token: String) -> int:
	return token.to_int()
