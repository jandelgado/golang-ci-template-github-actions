module github.com/jandelgado/golang-ci-template-github-actions

// minimal go version that must be used
go 1.25

// build with the go version automatically if GOTOOLCHAIN=auto is set
toolchain go1.27.0

require github.com/stretchr/testify v1.12.1

require go.yaml.in/yaml/v3 v3.0.5 // indirect
