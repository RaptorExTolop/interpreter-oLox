package main

import "core:strings"
import "core:bytes"
import "base:runtime"
import "core:fmt"
import "core:os"

main :: proc() {
	argv := os.args
	argc := len(os.args)

	allocator := context.temp_allocator
	defer free_all(allocator)

	if (argc > 2) {
		fmt.printf("Usage: jLox [script]\n")
		os.exit(64)
	}
	if (argc == 2) {
		err, code := run_file(argv[1], allocator)
		if (err != false) {
			os.exit(code)
		}
	} else {
		err, code := run_prompt(allocator)
		if (err != false) {
			os.exit(code)
		}
	}
}

run_file :: proc(file_name: string, allocator: runtime.Allocator) -> (error: bool, errCode: int){
	fmt.printf("Running file: {}\n", file_name)
	data, err := os.read_entire_file(file_name, allocator)
	if (err != nil) {
		fmt.printf("Error reading from file: {}\n", err)
		return true, 65
	}

	run(string(data), allocator)

	return false, 0
}

run_prompt :: proc(allocator: runtime.Allocator) -> (error: bool, errCode: int){
	fmt.printf("Welcome to the lox prompt! If you would like to exit, type: exit\n")
	for {
		fmt.printf(">>> ")

		buf: [1024]byte
		n, err := os.read(os.stdin, buf[:])

		if (err != nil) {
			fmt.printf("Error reading input: {}", err)
			return true, 64
		}

		input := strings.trim_space(string(buf[:n])) 

		if (input == "exit" || input == "") {
			return false, 0
		}

		fmt.printf("You have inputed: {}\n", input)

		e, code := run(input, allocator)

		if (e != false) {
			return true, code
		}
	}

	return false, 0
}

run :: proc(code: string, allocator: runtime.Allocator) -> (error: bool, exitCode: int) {
	new_scanner(code)

	return false, 0
}
