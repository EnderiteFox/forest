class_name CommandParser
extends RefCounted

## The argument types for tokens
enum ArgumentType {
	KEYWORD,
	STRING,
	JSON,
	INT,
	FLOAT,
	BOOL,
}

var command: String = ""
var current_index: int = 0

var parse_error: String = ""

var tokens: Array[String] = []
var token_types: Array[ArgumentType] = []

var preparse_mode: bool = false


## Replaces the last token with the given one. Can be used for auto-completion
static func replace_last_token(command: String, token: String) -> String:
	while not command.is_empty() and not _is_whitespace(command[-1]):
		command = command.substr(0, command.length() - 1)
	return command + token


## Returns [code]true[/code] if the String consists of only whitespaces, [code]false[/code] otherwise
static func _is_whitespace(string: String) -> bool:
	return string.strip_edges().is_empty()


## Initializes the parser with a command
func _init(command: String, preparse_mode: bool = false) -> void:
	self.command = command
	self.preparse_mode = preparse_mode


## Parses the command and extracts tokens.
## Returns [code]false[/code] if parsing fails, setting [code]parse_error[/code] to the corresponding error message,
## or [code]true[/code] on success
## Tokens are stored as Strings in [code]tokens[/code], and types in [code]token_types[/code]
func tokenize() -> bool:
	_consume_whitespace()
	while not _eof():
		_parse_argument()
		_consume_whitespace()
		if parse_error:
			return false
	return true
	
	
## Parses the next argument
func _parse_argument() -> void:
	if command[current_index] == '"':
		_parse_string_arg()
	elif command[current_index] == '{':
		_parse_json_arg()
	else:
		var token: String = _preparse_token()
		if token.is_valid_int():
			_add_token(token, ArgumentType.INT)
		elif token.is_valid_float():
			_add_token(token, ArgumentType.FLOAT)
		elif token in ["true", "false", "0b", "1b"]:
			_add_token(token, ArgumentType.BOOL)
		else:
			_add_token(token, ArgumentType.KEYWORD)
	
	
## Consumes a string, starting by a [code]"[/code] and ending with the first unescaped [code]"[/code]
func _parse_string_arg() -> void:
	current_index += 1 # Consume start quote
	var start_index: int = current_index
	while not _eof() and not (command[current_index] == '"' and not (current_index > 0 and command[current_index - 1] == '\\')):
		current_index += 1
		
	if _eof():
		parse_error = "Unclosed string argument at column %s" % (start_index - 1)
		if self.preparse_mode:
			_add_token(command.substr(start_index), ArgumentType.STRING)
		return
		
	if start_index == current_index:
		parse_error = "Internal Error: Trying to parse whitespace as token"
		return
		
	_add_token(command.substr(start_index, current_index - start_index), ArgumentType.STRING)
	current_index += 1 # Consume end quote
	
## Consumes a JSON argument. The JSON is parsed to make sure that it is valid
func _parse_json_arg() -> void:
	var start_index: int = current_index
	current_index += 1 # Consume first bracket
	var nesting_level: int = 1
	while nesting_level != 0:
		if _eof():
			parse_error = "Unclosed JSON argument at column %s" % start_index
			if self.preparse_mode:
				_add_token(command.substr(start_index), ArgumentType.JSON)
			return
		if command[current_index] == '{':
			nesting_level += 1
		elif command[current_index] == '}':
			nesting_level -= 1
		current_index += 1
		
	# Assert
	if start_index == current_index:
		parse_error = "Internal Error: Trying to parse whitespace as token"
		return
	
	# Check JSON syntax by parsing it
	var json_string: String = command.substr(start_index, current_index - start_index)
	var json := JSON.new()
	var json_parse_error = json.parse(json_string)
	if json_parse_error != Error.OK:
		parse_error = "Failed to parse JSON argument at column %s with error: %s" % [start_index, json.get_error_message()]
		return
		
	_add_token(json_string, ArgumentType.JSON)
	
	
## Preparses a token as a keyword and returns it without adding it as a token.
## Used for tokens that don't have a start character, like ints or floats, to determine the token type
func _preparse_token() -> String:
	var start_index: int = current_index
	while not _eof() and not _is_whitespace(command[current_index]):
		current_index += 1
	
	if start_index == current_index:
		parse_error = "Internal Error: Trying to preparse whitespace"
		return ""
	
	return command.substr(start_index, current_index - start_index)
	
	
## Consumes all following whitespaces, including space, \t, \n and \r
func _consume_whitespace() -> void:
	while not _eof() and _is_whitespace(command[current_index]):
		current_index += 1

	
## Returns [code]true[/code] if the parser reached the end of the command, [code]false[/code] otherwise
func _eof() -> bool:
	return current_index >= command.length()
	
	
## Adds a token, by taking a token String and its argument type
func _add_token(token: String, type: ArgumentType) -> void:
	tokens.append(token)
	token_types.append(type)
