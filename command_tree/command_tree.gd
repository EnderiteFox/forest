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
## Preparse mode disables some restrictions, allowing unfinished commands to be parsed
func get_command_path(
	tokens: Array[String], 
	token_types: Array[CommandParser.ArgumentType], 
	preparse_mode: bool = false
) -> Array[CommandTreeNode]:
	self.error = ""
	if tokens.size() != token_types.size():
		push_error("Invalid input: token count and token type count is different")
		return []
		
	var path: Array[CommandTreeNode] = []
	
	var current_node: Node = self
	for i in range(tokens.size()):
		var token: String = tokens[i]
		var token_type: CommandParser.ArgumentType = token_types[i]
		
		var children: Array[CommandTreeNode] = [] 
		children.assign(
			current_node.get_children().filter(
				func(node: Node): return node is CommandTreeNode
			)
		)
		
		var found_matching_node: bool = false
		for child in children:
			if not child.accepts_token_type(token_type):
				continue
			if not child.accepts_token(token, preparse_mode):
				continue
			
			if found_matching_node:
				if preparse_mode:
					return path
				error = "Ambiguous command tree: token %s matches both %s and %s" % [token, node_to_string(path[-1]), node_to_string(child)]
				return []
			
			path.append(child)
			current_node = child
			found_matching_node = true
		
		if path.size() != i + 1:
			if preparse_mode:
				return path
			
			# Didn't find a matching node
			error = "Unexpected argument: %s" % token
			return []
		
	var children: Array[CommandTreeNode] = []
	current_node.get_children().filter(
		func(node: Node): return (node is Command) or ((node is CommandTreeArgument) and not node.is_optional())
	).filter(children.append)
	
	if not children.is_empty() and not preparse_mode:
		self.error = "Missing command arguments!\nExpecting one of the following:\n%s" % "\n".join(
			children.map(node_to_string)
		)
		
	return path
	
	
func execute_callback(command_path: Array[CommandTreeNode], tokens: Array[String]) -> void:
	self.error = ""
	
	# Get arguments
	var argument_names: Array[String] = []
	var arguments: Array[Variant] = []
	var token_index: int = 0
	for node in command_path:
		if not node is CommandTreeArgument:
			token_index += 1
			continue
			
		argument_names.append(node.argument_name)
		arguments.append(node.parse_token(tokens[token_index]))
		token_index += 1
	
	# Find last command node
	var inverted_command_path: Array[CommandTreeNode] = command_path.duplicate(true)
	inverted_command_path.reverse()
	var command_node: Command = null
	
	for node in inverted_command_path:
		if node is Command:
			command_node = node
			break
			
	if not command_node:
		self.error = "No command node in command path"
		return
		
	if not command_node.command_callbacks.has(argument_names):
		self.error = "No function matches arguments %s" % ", ".join(argument_names)
		return

	var custom_callback: CustomCallback = command_node.command_callbacks[argument_names]
	var node: Node = command_node.get_node(custom_callback.node)
	if not node:
		self.error = "Could not find node at path %s from node %s" % [custom_callback.node, command_node.get_name()]
	node.callv(custom_callback.callback, arguments)
	
	
func get_autocomplete_suggestions(command: String) -> Array[String]:
	var command_parser := CommandParser.new(command, true)
	command_parser.tokenize()
	
	var command_path: Array[CommandTreeNode] = self.get_command_path(
		command_parser.tokens,
		command_parser.token_types, 
		true
	)
	
	var ends_with_whitespace: bool = command.length() == 0 or command[-1].strip_edges().is_empty()
	
	var last_token: String = command_parser.tokens[-1] if command_parser.tokens.size() > 0 and not ends_with_whitespace else ""
	
	var last_node: Node = command_path[-1] if command_path.size() != 0 else self
	
	return _get_node_autocompletion(last_node, last_token, ends_with_whitespace)
	
	
func _get_node_autocompletion(node: Node, last_token: String, ends_with_whitespace: bool) -> Array[String]:
	if ends_with_whitespace:
		var suggestions: Array[String] = []
		for child in node.get_children():
			if child is CommandTreeNode:
				suggestions.append_array(child.get_autocomplete_suggestions(""))
		return suggestions
	else:
		if node is CommandTreeArgument:
			return node.get_autocomplete_suggestions(last_token)
		elif node is Command:
			if node.command_name.begins_with(last_token) and (node.get_parent() is CommandTreeNode or node.get_parent() is CommandTree):
				return _get_node_autocompletion(node.get_parent(), last_token, false)
				
			var suggestions: Array[String] = []
			for child in node.get_children():
				if child is CommandTreeNode:
					suggestions.append_array(child.get_autocomplete_suggestions(last_token))
			return suggestions
		elif node is CommandTree:
			var suggestions: Array[String] = []
			for child in node.get_children():
				if child is Command:
					suggestions.append_array(child.get_autocomplete_suggestions(last_token))
			return suggestions
		
	push_error("Internal Error: Trying to get autocompletion from unexpected node type")
	return []
