package main

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func ExampleHello() {
	Hello()
	// Output:
	// hello, world!
}

func TestHello(t *testing.T) {
	require.NoError(t, Hello())
}
