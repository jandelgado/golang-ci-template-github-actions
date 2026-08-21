package main

import "fmt"

// will be set by linker during build
var (
	BuildVersion = "(version)"
	BuildCommit  = "(commit)"
)

// Hello just says hello
func Hello() error {
	fmt.Println("hello, world!")
	return nil
}

func main() {
	Hello() // return value intentionally not checked to trigger linter
	fmt.Printf("version: %s (commit %s)\n", BuildVersion, BuildCommit)
}
