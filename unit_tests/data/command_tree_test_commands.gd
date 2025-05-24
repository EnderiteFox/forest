class_name CommandTreeTestCommands
extends Node

var execute_no_args: bool = false

var int_arg_executed: bool = false
var int_arg: int = 0

var enum_arg_executed: bool = false
var enum_arg: String = ""

var addition_executed: bool = false
var addition_result: float = 0.0

var string_arg_executed: bool = false
var string_arg: String = ""

var json_arg_executed: bool = false
var json_arg: Variant = {}


func validate_execute_no_args() -> void:
	execute_no_args = true
	
	
func validate_execute_int_arg(value: int) -> void:
	int_arg_executed = true
	int_arg = value
	
	
func validate_execute_enum_arg(enum_value: String) -> void:
	enum_arg_executed = true
	enum_arg = enum_value
	
	
func validate_addition(value1: float, value2: float) -> void:
	addition_executed = true
	addition_result = value1 + value2
	
	
func validate_string_arg(value: String) -> void:
	string_arg_executed = true
	string_arg = value
	
	
func validate_json_arg(value: Variant) -> void:
	json_arg_executed = true
	json_arg = value
	