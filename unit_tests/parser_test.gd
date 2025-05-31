extends TestSuite

var parser: CommandParser


func _init() -> void:
	super._init("Parser")


func test_empty() -> void:
	parser = CommandParser.new("")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_empty(parser.tokens)
		assert_empty(parser.token_types)


func test_single_keyword() -> void:
	parser = CommandParser.new("command")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["command"])
		assert_eq(parser.token_types, [CommandParser.ArgumentType.KEYWORD])
		

func test_multiple_keywords() -> void:
	parser = CommandParser.new("hello there")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["hello", "there"])
		assert_eq(
			parser.token_types,
				[
					CommandParser.ArgumentType.KEYWORD, 
					CommandParser.ArgumentType.KEYWORD
				]
		)
		
		
func test_int() -> void:
	parser = CommandParser.new("hello 1")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["hello", "1"])
		assert_eq(parser.token_types, [
			CommandParser.ArgumentType.KEYWORD,
			CommandParser.ArgumentType.INT])
		

func test_float() -> void:
	parser = CommandParser.new("hello 1.0")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["hello", "1.0"])
		assert_eq(parser.token_types, [
		CommandParser.ArgumentType.KEYWORD,
		CommandParser.ArgumentType.FLOAT])
		
		
func test_string() -> void:
	parser = CommandParser.new("hello \"there\"")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["hello", "there"])
		assert_eq(parser.token_types, [
		CommandParser.ArgumentType.KEYWORD,
		CommandParser.ArgumentType.STRING])
		
		
func test_string_unclosed() -> void:
	parser = CommandParser.new("hello \"unclosed string")
	parser.tokenize()
	assert_true(parser.parse_error)
		
		
func test_boolean_true() -> void:
	parser = CommandParser.new("hello true 1b")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["hello", "true", "1b"])
		assert_eq(parser.token_types, [
		CommandParser.ArgumentType.KEYWORD,
		CommandParser.ArgumentType.BOOL,
		CommandParser.ArgumentType.BOOL])
		
		
func test_boolean_false() -> void:
	parser = CommandParser.new("hello false 0b")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, ["hello", "false", "0b"])
		assert_eq(parser.token_types, [
		CommandParser.ArgumentType.KEYWORD,
		CommandParser.ArgumentType.BOOL,
		CommandParser.ArgumentType.BOOL])
		
		
func test_json_valid() -> void:
	parser = CommandParser.new("hello {\"messages\": [{\"content\": \"Hello there\", \"sender\": \"General Kenobi\"}]}")
	parser.tokenize()
	if assert_false(parser.parse_error):
		assert_eq(parser.tokens, [
			"hello", 
			"{\"messages\": [{\"content\": \"Hello there\", \"sender\": \"General Kenobi\"}]}"])
		assert_eq(parser.token_types, [
			CommandParser.ArgumentType.KEYWORD, 
			CommandParser.ArgumentType.JSON])
		
		
func test_json_invalid() -> void:
	parser = CommandParser.new("hello {somerandom: invalid []data}")
	parser.tokenize()
	assert_true(parser.parse_error)
	
	
func test_json_unclosed() -> void:
	parser = CommandParser.new("hello {\"unclosed\": \"json object\"")
	parser.tokenize()
	assert_true(parser.parse_error)
	
	
func test_replace_last_token() -> void:
	assert_eq(CommandParser.replace_last_token("time set day", "night"), "time set night")
	
	
func test_replace_last_token_empty() -> void:
	assert_eq(CommandParser.replace_last_token("", "hello"), "hello")
	
	
func test_replace_last_token_only_one() -> void:
	assert_eq(CommandParser.replace_last_token("hello", "there"), "there")
