class_name CommandTreeNode
extends Node

## If [code]true[/code], this CommandTreeNode is optional
@export var optional: bool = false

## Returns [code]true[/code] if this argument accepts this token type, [code]false[/code] otherwise
func accepts_token_type(_token_type: CommandParser.ArgumentType) -> bool:
	push_error("accepts_token_type not implemented for argument")
	return false
	

## Returns [code]true[/code] if this node accepts the given token, [code]false[/code] otherwise
func accepts_token(_token: String) -> bool:
	push_error("accepts_token not implemented for argument")
	return false
	
	
## Returns [code]true[/code] if this node is optional, [code]false[/code] otherwise
func is_optional() -> bool:
	return optional


## Returns [code]true[/code] if this command node is the end of a command
## which is if there is no non-optional children
func is_command_end() -> bool:
	return not get_children().filter(
		func(node: Node): node is CommandTreeNode)\
	.any(\
		func(node: CommandTreeNode): not node.is_optional()
	)
