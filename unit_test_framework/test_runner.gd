class_name TestRunner
extends RefCounted

var test_suites: Dictionary[String, TestSuite] = {}


func add_test_suites_in_folder(path: String) -> void:
	var directory_content: PackedStringArray = ResourceLoader.list_directory(path)

	for file in directory_content:
		if DirAccess.dir_exists_absolute(path.path_join(file)):
			continue
			
		var resource: Resource = load(path.path_join(file))
		if not resource is Script:
			continue

		var script_instance = (resource as Script).new()
		if not script_instance is TestSuite:
			script_instance.free()
			continue

		test_suites[script_instance.suite_name] = script_instance


func add_test_suite(name: String, suite: TestSuite) -> void:
	test_suites[name] = suite


func run_all_tests() -> void:
	var test_suite_count: int = 0
	var total_test_count: int = 0
	var total_success_count: int = 0
	var total_fail_count: int = 0
	var failed_tests: Array[String] = []
	var failed_to_get_lines: bool = false
	var total_time: float = 0
	for test_suite_name in test_suites:
		test_suite_count += 1
		var test_suite_result: Dictionary = run_test_suite(test_suite_name, test_suites[test_suite_name])
		total_test_count += test_suite_result["total_tests"]
		total_fail_count += test_suite_result["failed_tests"]
		total_success_count += test_suite_result["total_tests"] - test_suite_result["failed_tests"]
		total_time += test_suite_result["total_time"]
		failed_tests.append_array(
			test_suite_result["failed_test_names"].map(
				func(test_name: String): return "%s.%s" % [test_suite_name, test_name]
			)
		)
		failed_to_get_lines = failed_to_get_lines or test_suite_result["failed_to_get_lines"]
		
	print()
	print_rich(
		"Test results: [color=%s][%s] (%s / %s)[/color] (%s)" % (
			["red", "FAILED", total_success_count, total_test_count, _get_time_string(total_time)] if total_fail_count > 0 
			else ["green", "SUCCESS", total_success_count, total_test_count, _get_time_string(total_time)]
		)
	)
	if total_fail_count > 0:
		print_rich("[color=red]%s test%s failed:[/color]" % [total_fail_count, "s" if total_fail_count > 1 else ""])
		for failed_test in failed_tests:
			print_rich("\t[color=red]%s[/color]" % failed_test)
			
	if failed_to_get_lines:
		push_warning("Line numbers could not be displayed because the tests were not run in a debug environment (in the editor). Run tests in the editor to get error line numbers")
	


static func _get_test_name(method_name: String) -> String:
	return method_name.trim_prefix("test_").capitalize().replace(" ", "")
	

static func _get_time_string(time: float) -> String:
	return ("%.2fs" % time) if time >= 1 else ("%dms" % (time / 1000))


static func run_test_suite(name: String, test_suite: TestSuite) -> Dictionary:
	var suite_failed: bool        = false
	var test_results: Dictionary  = {
		"total_tests": 0, 
		"failed_tests": 0, 
		"tests_passed": 0, 
		"failed_test_names": [], 
		"failed_to_get_lines": false,
		"total_time": 0
	}

	print("== %s ==" % name)

	for method_dict in test_suite.get_method_list():
		if not method_dict["name"].begins_with("test"):
			continue
		if not method_dict["args"].is_empty():
			push_warning("Test %s takes argument, skipping" % method_dict["name"])
			continue

		var test_name: String = _get_test_name(method_dict["name"])
		test_results["total_tests"] += 1

		test_suite.failed = []
		test_suite.setup()

		print("Running %s.%s" % [name, test_name])

		var start: float = Time.get_unix_time_from_system()
		test_suite.callv(method_dict["name"], [])
		var end: float = Time.get_unix_time_from_system()
		
		test_results["total_time"] += end - start
		
		var time_string: String = _get_time_string(end - start)
		
		test_suite.cleanup()

		if test_suite.failed:
			suite_failed = true
			test_results["failed_tests"] += 1
			test_results["failed_test_names"].append(test_name)
			for error in test_suite.failed:
				if (error["line"]):
					print_rich("[color=red]Line %s: %s[/color]" % [error["line"], error["message"]])
				else:
					test_results["failed_to_get_lines"] = true
					print_rich("[color=red]%s[/color]" % error["message"])
			print_rich("[color=red][FAIL] %s.%s[/color] (%s)" % [name, test_name, time_string])
		else:
			test_results["tests_passed"] += 1
			print_rich("[color=green][OK][/color] (%s)" % time_string)

	print_rich(
		"== [color=%s][%s] (%s / %s)[/color] (%s) ==" % (
			[
				"red", 
				"FAILED", 
				test_results["tests_passed"], 
				test_results["total_tests"], 
				_get_time_string(test_results["total_time"])
			] if suite_failed 
			else [
				"green", 
				"SUCCESS", 
				test_results["tests_passed"], 
				test_results["total_tests"], 
				_get_time_string(test_results["total_time"])
			]
		)
	)
	print()

	return test_results
