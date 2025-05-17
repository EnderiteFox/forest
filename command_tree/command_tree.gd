@tool
class_name CommandTree
extends Node

var error: String = ""

## Turns a command tree node into a String for debug
## If the node is a command argument, returns the argument name
## If the node is a command and the child of a command, returns the name of the parent command, as well as its own command name
## If the node is at the root of the command tree and is a command, returns the name of the command
## If the node has a script, returns the name of the node and its class name (should probably not happen)
## If the node has no script, returns the name of the node (definitely shouldn't happen)
static func node_to_string(node: CommandTreeNode) -> String:
	if node is CommandTreeArgument:
		return node.argument_name

	var parent: Node = node.get_parent()
	if node is Command and parent is Command:
		return "%s subcommand %s" % [parent.command_name, node.command_name]

	if node is Command and parent is CommandTree:
		return "%s command" % node.command_name

	var script: Script = node.get_script()
	if script:
		return "%s (%s)" % [node.get_name(), script.get_global_name()]

	return node.get_name()


## Finds a command path matching the given tokens
func get_command_path(tokens: Array[String], token_types: Array[CommandParser.ArgumentType]) -> Array[CommandTreeNode]:
	if tokens.size() != token_types.size():
		push_error("Internal Error: token count and token type count is different")
		return []
		
	var path: Array[CommandTreeNode] = []
	
	var current_node: Node = self
	for i in range(tokens.size()):
		var token: String = tokens[i]
		var token_type: CommandParser.ArgumentType = token_types[i]
		
		var children: Array[CommandTreeNode] = []
		current_node.get_children().filter(
			func(node): return node is CommandTreeNode
		).filter(children.append)
		
		var found_matching_node: bool = false
		for child in children:
			if child.get_token_type() != token_type:
				continue
			if not child.accepts_token(token):
				continue
			
			if found_matching_node:
				error = "Ambiguous command tree: token %s matches both %s and %s" % [token, node_to_string(path[-1]), node_to_string(child)]
				return []
			
			path.append(child)
			current_node = child
			found_matching_node = true
		
		if path.size() != i + 1:
			# Didn't find a matching node
			error = "Unexpected argument: %s" % token
			return []
		
	return path
