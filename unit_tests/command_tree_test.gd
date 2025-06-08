extends TestSuite

var command_tree_scene: PackedScene = preload("res://addons/forest/unit_tests/data/command_tree_test.tscn")
var command_tree: CommandTree
var test_commands: CommandTreeTestCommands

func _init() -> void:
	super._init("CommandTree")
	

func setup() -> void:
	command_tree = command_tree_scene.instantiate()
	test_commands = command_tree.get_node(^"CommandTreeTestCommands")
	
	
func cleanup() -> void:
	command_tree.free()
	
	
func assert_path_equal(command: String, expected_path: Array[StringName]) -> bool:
	var command_parser := CommandParser.new(command)
	command_parser.tokenize()
	
	if command_parser.parse_error:
		mark_test_failed("Unexpected parse error:\n%s" % command_parser.parse_error)
		return false
		
	var command_path: Array[CommandTreeNode] = command_tree.get_command_path(
	   command_parser.tokens, 
	   command_parser.token_types
   	)
	
	if command_tree.error:
		mark_test_failed("Unexpected error:\n%s" % command_tree.error)
		return false
	
	var node_names: Array = command_path.map(
		func(node: CommandTreeNode): return node.get_name()
	)
	
	if node_names != expected_path:
		mark_test_failed("Expected equality between \"%s\" and \"%s\"" % [str(node_names), str(expected_path)])
		return false
		
	return true
	
	
func assert_get_path_fails(command: String) -> bool:
	var command_parser := CommandParser.new(command)
	command_parser.tokenize()
	if not assert_false(command_parser.parse_error):
		return false
		
	command_tree.get_command_path(
		command_parser.tokens,
		command_parser.token_types
	)
	return assert_true(command_tree.error)
	
	
func assert_execute_succeeds(command: String) -> bool:
	var command_parser := CommandParser.new(command)
	command_parser.tokenize()
	if command_parser.parse_error:
		mark_test_failed("Unexpected error:\n%s" % command_parser.parse_error)
		return false;
		
	var command_path: Array[CommandTreeNode] = command_tree.get_command_path(
		command_parser.tokens, 
		command_parser.token_types
	)
	
	if command_tree.error:
		mark_test_failed("Unexpected error:\n%s" % command_tree.error)
		return false
		
	command_tree.execute_callback(command_path, command_parser.tokens)
	if command_tree.error:
		mark_test_failed("Unexpected error:\n%s" % command_tree.error)
		return false
		
	return true
	
	
func test_get_path_empty() -> void:
	var tokens: Array[String] = []
	var token_types: Array[CommandParser.ArgumentType] = []
	assert_empty(command_tree.get_command_path(tokens, token_types))
	
	
func test_get_path_keyword_only1() -> void:
	assert_path_equal(
		"keyword only command",
		[&"Keyword", &"Only", &"Command"]
	)
		
		
func test_get_path_keyword_only2() -> void:
	assert_path_equal(
		"keyword only cmd",
		[&"Keyword", &"Only", &"Cmd"]
	)
		
		
func test_get_path_int() -> void:
	assert_path_equal(
		"time set 0",
		[&"Time", &"Set", &"TimeInTicks"]
	)
		
		
func test_get_path_enum() -> void:
	for time_of_day in ["day", "night", "noon", "midnight"]:
		assert_path_equal(
			"time set %s" % time_of_day,
			[&"Time", &"Set", &"TimeOfDay"]
		)
		
		
func test_get_path_float() -> void:
	assert_path_equal(
		"add 2.0 1.0",
		[&"Add", &"Num1", &"Num2"]
	)
	
	
func test_get_path_string() -> void:
	assert_path_equal(
		"print \"Hello there\"",
		[&"Print", &"Text"]
	)
	
	
func test_get_path_json() -> void:
	assert_path_equal(
		"print {\"messages\": [{\"content\": \"Hello there\", \"sender\": \"General Kenobi\"}]}",
		[&"Print", &"Json"]
	)
	
	
func test_get_path_bool() -> void:
	for bool in ["true", "false", "0b", "1b"]:
		assert_path_equal(
			"set_bool %s" % bool,
			[&"SetBool", &"Bool"]
		)
	
	
func test_get_path_case_sensitive() -> void:
	assert_get_path_fails("Print \"Hello there\"")
	
	
func test_get_path_ambiguous() -> void:
	assert_get_path_fails("ambiguous keyword")
	

func test_get_path_optional_argument_present() -> void:
	assert_path_equal(
		"damage \"EnderiteFox\" 1.0 false",
		[&"Damage", &"Player", &"Amount", &"BypassArmor"]
	)
	
	
func test_get_path_optional_argument_not_present() -> void:
	assert_path_equal(
		"damage \"EnderiteFox\" 1.0",
		[&"Damage", &"Player", &"Amount"]
	)
	
	
func test_get_path_not_ambiguous_keyword_vs_enum() -> void:
	if assert_path_equal(
		"ambiguous vsenum keyword",
		[&"Ambiguous", &"VsEnum", &"Keyword"]
	):
		assert_path_equal(
			"ambiguous vsenum notkeyword",
			[&"Ambiguous", &"VsEnum", &"EnumArgument"]
		)
	
	
func test_get_path_non_optional_argument_not_present() -> void:
	assert_get_path_fails("damage \"EnderiteFox\"")
	
	
func test_execute_no_args() -> void:
	if assert_execute_succeeds("hello"):
		assert_true(test_commands.execute_no_args)
		

func test_execute_int_arg() -> void:
	if assert_execute_succeeds("time set 10"):
		assert_true(test_commands.int_arg_executed)
		assert_eq(test_commands.int_arg, 10)
		
		
func test_execute_enum_arg() -> void:
	for time_of_day in ["day", "night", "noon", "midnight"]:
		test_commands.enum_arg_executed = false
		test_commands.enum_arg = ""
		if assert_execute_succeeds("time set %s" % time_of_day):
			assert_true(test_commands.enum_arg_executed)
			assert_eq(test_commands.enum_arg, time_of_day)
		
		
func test_execute_float_arg_addition() -> void:
	if assert_execute_succeeds("add 1.0 2.0"):
		assert_true(test_commands.addition_executed)
		assert_eq(test_commands.addition_result, 3.0)
		
	
func test_execute_float_arg_as_int() -> void:
	if assert_execute_succeeds("add 1 2"):
		assert_true(test_commands.addition_executed)
		assert_eq(test_commands.addition_result, 3.0)
		
		
func test_execute_string_arg() -> void:
	if assert_execute_succeeds("print \"Hello there\""):
		assert_true(test_commands.string_arg_executed)
		assert_eq(test_commands.string_arg, "Hello there")
		
		
func test_execute_json_arg() -> void:
	if assert_execute_succeeds("print {\"messages\": [{\"content\": \"Hello there\", \"sender\": \"General Kenobi\"}]}"):
		assert_true(test_commands.json_arg_executed)
		assert_eq(test_commands.json_arg,
			{
				"messages": [
					{
						"content": "Hello there",
						"sender": "General Kenobi"
					}
				]
			}
		)
