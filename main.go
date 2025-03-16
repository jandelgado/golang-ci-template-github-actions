package main

import "fmt"

// Hello just says hello
func Hello() error {
	fmt.Println("hello, world!")
	return nil
}

func main() {
	Hello()     // should trigger linter
}