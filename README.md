# golang ci template using github actions

**WORK IN PROGRESS**

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

Using the [coveralls github action](https://github.com/marketplace/actions/coveralls-github-action) and
converting coverage information to lcov-format before.


Don't forget to enable `Leave comments (x) ` in coveralls, under `repo
settings` > `pull request alerts`.  
