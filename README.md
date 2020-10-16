# golang ci template using github actions


[![Build Status](https://github.com/jandelgado/golang-ci-template-github-actions/workflows/test%20and%20build/badge.svg)](https://github.com/jandelgado/golang-ci-template-github-actions/actions?workflow=test%20and%20build)
[![Coverage Status](https://coveralls.io/repos/github/jandelgado/golang-ci-template-github-actions/badge.svg?branch=master)](https://coveralls.io/github/jandelgado/golang-ci-template-github-actions?branch=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/jandelgado/golang-ci-template-github-actions)](https://goreportcard.com/report/github.com/jandelgado/golang-ci-template-github-actions) 


<!-- vim-markdown-toc GFM -->

* [Info](#info)
* [Creating a release](#creating-a-release)
* [Test coverage (coveralls)](#test-coverage-coveralls)
* [Author](#author)

<!-- vim-markdown-toc -->

## Info 

This repository serves as a template for github-actions integrated go projects.
It consists of a `hello, world!` like example in source file `main.go` which
gets compiled into binary `golang-ci-template-github-actions`. The CI runs some
[linters](https://github.com/golangci/golangci-lint-action) on the code, before
the unit tests are executed. When the build stage was successful, build
artifacts are uploaded and available in the CI job status.

For demonstration purposes, a linux, macos and windows target are created and
packetized in a zip-archive.

## Creating a release

On your repositories home (github.com) go to `Releases` > `create release`.
When a new release is created, the released-artifacts are automatically
uploaded to github and available on the [releases page](/releases)

## Test coverage (coveralls)

We use the
[gcov2lcov-action](https://github.com/marketplace/actions/gcov2lcov-action) to
first convert the golang test coverage to lcov format and then upload it using
the [coveralls github
action](https://github.com/marketplace/actions/coveralls-github-action).

Don't forget to enable `Leave comments (x) ` in coveralls, under `repo
settings` > `pull request alerts`, so that the coveralls-action posts a comment
with the test coverage to affected pull requests:

![pr screenshot](images/pr.png)

## Author

Jan Delgado

