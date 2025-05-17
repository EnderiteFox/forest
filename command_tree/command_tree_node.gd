class_name CommandTreeNode
extends Node

## Returns the type of token accepted by this command node
func get_token_type() -> CommandParser.ArgumentType:
	push_error("Undefined CommandTreeNode token type, defaulting to KEYWORD")
	return CommandParser.ArgumentType.KEYWORD
	

## Returns [code]true[/code] if this node accepts the given token, [code]false[/code] otherwise
func accepts_token(token: String) -> bool:
	return false
	
	
## Returns [code]true[/code] if this node is optional, [code]false[/code] otherwise
func is_optional() -> bool:
	return false


## Returns [code]true[/code] if this command node is the end of a command
## which is if there is no non-optional children
func is_command_end() -> bool:
	return not get_children().filter(
		func(node): node is CommandTreeNode)\
	.any(\
		func(node): not node.is_optional()
	)
