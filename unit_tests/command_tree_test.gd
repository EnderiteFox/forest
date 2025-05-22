extends TestSuite

var command_tree_scene: PackedScene = preload("res://addons/forest/unit_tests/data/command_tree_test.tscn")
var command_tree: CommandTree

func _init() -> void:
	super._init("CommandTree")
	

func setup() -> void:
	command_tree = command_tree_scene.instantiate()
	
	
func cleanup() -> void:
	command_tree.free()
	
	
func assert_path_equal(command: String, expected_path: Array[StringName]) -> bool:
	var command_parser := CommandParser.new(command)
	command_parser.tokenize()
	if not assert_false(command_parser.parse_error):
		return false
		
	var command_path: Array[CommandTreeNode] = command_tree.get_command_path(
	   command_parser.tokens, 
	   command_parser.token_types
   	)
	
	return assert_eq(
		command_path.map(
			func(node: CommandTreeNode): return node.get_name()
		),
		expected_path
	)
	
	
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
