class_name TestSuite
extends RefCounted

var suite_name: String        = "UnnamedTestSuite"
var failed: Array[Dictionary] = []


func _init(suite_name: String) -> void:
	self.suite_name = suite_name


func setup() -> void:
	pass


func cleanup() -> void:
	pass


func mark_test_failed(message: String) -> void:
	var stack: Array[Dictionary] = get_stack()
	var error_dict: Dictionary[String, String] = {}
	if stack and stack.size() > 2:
		error_dict["line"] = str(stack[2]["line"])

	error_dict["message"] = message
	failed.append(error_dict)


func assert_empty(array: Array) -> bool:
	if not array.is_empty():
		mark_test_failed("Expected empty array, got \"%s\" instead" % str(array))
		return false
	return true
	
	
func assert_not_empty(array: Array) -> bool:
	if array.is_empty():
		mark_test_failed("Expected non-empty array")
		return false
	return true


func assert_true(value: Variant) -> bool:
	if not value:
		mark_test_failed("Expected true, got \"%s\"" % str(value))
		return false
	return true


func assert_false(value: Variant) -> bool:
	if value:
		mark_test_failed("Expected false, got \"%s\"" % str(value))
		return false
	return true
		

func assert_eq(value1: Variant, value2: Variant) -> bool:
	if value1 != value2:
		mark_test_failed("Expected equality between \"%s\" and \"%s\"" % [str(value1), str(value2)])
		return false
	return true
		
		
func assert_ne(value1: Variant, value2: Variant) -> bool:
	if value1 == value2:
		mark_test_failed("Expected inequality between \"%s\" and \"%s\"" % [str(value1), str(value2)])
		return false
	return true
		
		
func assert_in(value: Variant, array: Array) -> bool:
	if not value in array:
		mark_test_failed("Expected \"%s\" to be in %s" % [str(value), str(array)])
		return false
	return true

	
func assert_in_dict(value: Variant, dict: Dictionary) -> bool:
	if not value in dict:
		mark_test_failed("Expected \"%s\" to be in %s" % [str(value), str(dict)])
		return false
	return true
	
	
func assert_array_size(array: Array, size: int) -> bool:
	if array.size() != size:
		mark_test_failed("Expected an array of size %s, got size %s" % [str(size), str(array.size())])
		return false
	return true
	
	
func assert_string_match(string: String, pattern: String) -> bool:
	var regex := RegEx.create_from_string(pattern)
	if not regex.search(string):
		mark_test_failed("Expected \"%s\" to match \"%s\"" % [string, pattern])
		return false
	return true
