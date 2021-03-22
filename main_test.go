package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestWeAreGreeted(t *testing.T) {
	assert.Equal(t, "Hello, Jan", sayHelloTo("Jan"))
}
