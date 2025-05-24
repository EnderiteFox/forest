class_name CommandTreeArgument
extends CommandTreeNode

@export var argument_name: String

## Takes the command node argument as a String and returns the corresponding parsed object
func parse_token(_token: String) -> Variant:
	push_error("Internal Error: Argument not implemented")
	return null
