extends TestSuite

var command_tree_scene: PackedScene = preload("res://addons/forest/unit_tests/data/command_tree_test.tscn")
var command_tree: CommandTree

func _init() -> void:
	super._init("Autocompletion")


func setup() -> void:
	command_tree = command_tree_scene.instantiate()


func cleanup() -> void:
	command_tree.free()
	
	
func test_command_base_key() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("key"), ["keyword"])
	
	
func test_multiple_similar_commands() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("similar hell"), ["hello", "hello_there"])
	
	
func test_multiple_similar_commands_space() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("similar "), ["hello", "hello_there"])
	
	
func test_bool_not_started() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("set_bool "), ["true", "false", "0b", "1b"])
	
	
func test_bool_start() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("set_bool tr"), ["true"])
	
	
func test_different_commands() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("multiple fir"), ["first"])
	
	
func test_different_commands_space() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("multiple "), ["first", "second"])
	
	
func test_enum_arg() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("time set "), ["day", "night", "noon", "midnight"])
	
	
func test_enum_arg_partial() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("time set n"), ["night", "noon"])
	
	
func test_command_end_still_shows() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("time"), ["time"])
	
	
func test_arg_end_still_shows() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("time set day"), ["day"])
	
	
func test_keyword() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("param key"), ["keyword"])
	
	
func test_after_keyword() -> void:
	assert_same_array(command_tree.get_autocomplete_suggestions("spawn the_shade r"), ["random"])
