class_name FloatArgument
extends CommandTreeArgument

## If [code]true[/code], also accepts INT tokens
@export var accepts_ints: bool = true


func accepts_token_type(token_type: CommandParser.ArgumentType) -> bool:
	return token_type == CommandParser.ArgumentType.FLOAT or (
		accepts_ints and token_type == CommandParser.ArgumentType.INT
	)
	
func accepts_token(token: String) -> bool:
	return token.is_valid_float()
	
	
func parse_token(token: String) -> float:
	return token.to_float()
