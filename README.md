# golang ci template using github actions

[![Coverage Status](https://coveralls.io/repos/github/jandelgado/golang-ci-template-github-actions/badge.svg?branch=master)](https://coveralls.io/github/jandelgado/golang-ci-template-github-actions?branch=master) 
[![Go Report Card](https://goreportcard.com/badge/github.com/jandelgado/golang-ci-template-github-actions)](https://goreportcard.com/report/github.com/jandelgado/golang-ci-template-github-actions) 


<!-- vim-markdown-toc GFM -->

* [Info](#info)
* [Creating a release](#creating-a-release)
* [Test coverage (coveralls)](#test-coverage-coveralls)

<!-- vim-markdown-toc -->

# Info 
This repository serves as a template for github-actions integrated go projects.  It
consists of a `hello, world!` like example in source file `main.go` which gets
compiled into binary `ci-test`. The `pre-commit` script runs some checks on the
code. 

When a new release is created, the released-artifacts are automatically
uploaded to github and available on the [release
page](https://github.com/jandelgado/ci-test/releases/)i (TODO).  

For demonstration purposes, both a linux- and windows target is created and
packetized in a zip-archive.

# Creating a release

On your repositories home (github.com) go to `Releases` > `create realease`.
As soon as the release-tag is created, Travis will run the deployment step.
(TODO)

# Test coverage (coveralls)

Create coveralls account and activate coveralls for repositiory. In github,
create a secret `COVERALLS_TOKEN` with the api token. (TODO)

