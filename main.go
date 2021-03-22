package main

import (
	"fmt"

	log "github.com/sirupsen/logrus"
)

func sayHelloTo(who string) string {
	return fmt.Sprintf("Hello, %s", who)
}

func main() {
	log.Info(sayHelloTo("Jan"))
}
