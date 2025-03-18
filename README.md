# golang ci template using github actions

[![Build Status](https://github.com/jandelgado/golang-ci-template-github-actions/workflows/test%20and%20build/badge.svg)](https://github.com/jandelgado/golang-ci-template-github-actions/actions?workflow=test%20and%20build)
[![Coverage Status](https://coveralls.io/repos/github/jandelgado/golang-ci-template-github-actions/badge.svg?branch=master)](https://coveralls.io/github/jandelgado/golang-ci-template-github-actions?branch=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/jandelgado/golang-ci-template-github-actions)](https://goreportcard.com/report/github.com/jandelgado/golang-ci-template-github-actions)

<!-- vim-markdown-toc GFM -->

* [Info](#info)
* [Go-Version](#go-version)
* [Dependabot](#dependabot)
* [Creating a release](#creating-a-release)
* [Test coverage (coveralls)](#test-coverage-coveralls)
* [Author](#author)

<!-- vim-markdown-toc -->

## Info

This repository serves as a template for github-actions integrated go projects.
It consists of a `hello, world!` like example in source file [main.go](main.go)
which gets compiled into the binary `my-app` using goreleaser. The CI
runs some [linters](https://github.com/golangci/golangci-lint-action) on the
code, before the unit tests are executed. Test coverage is uploaded to
coveralls.io.

[goreleaser](https://github.com/goreleaser/goreleaser) is used to create the
final multi-plattform assets, which are automatically uploaded to the
[release](https://github.com/jandelgado/golang-ci-template-github-actions/releases/latest).
The [release-process](#creating-a-release) is triggered by pushing a git tag to
the repository.

Finally, a docker image is built, which gets published to
[ghcr.io](https://github.com/jandelgado/golang-ci-template-github-actions/pkgs/container/my-app).
Run it with

```console
$ docker run --rm  ghcr.io/jandelgado/my-app:latest
hello, world!
```

## Go-Version

The go version to use is configured in `go.mod` with the `toolchain` directive.
When building locally, set `GOTOOLCHAIN` to `auto` to automatically install
the configured toolchain.

## Dependabot

We use [dependabot](https://docs.github.com/en/code-security/dependabot) to
both keep the go dependencies as well as the used github action up-to-date.
The configuration can be found [here](.github/dependabot.yml).

## Creating a release

A new release is created by creating a git tag and pushing it, e.g.:

```console
$ git tag -a "v1.2.3" -m "this is release v1.2.3"
$ git push origin v1.2.3
```

The push of the new tag triggers the CI, which uses goreleaser with
 [this configuration](.goreleaser.yml) to

* build multi-platform release artifacts
* create a new release
* upload the artifacts, which are then available on the [releases page](/jandelgado/golang-ci-template-github-actions/releases).

Finally, a docker image is built, which gets published to
[ghcr.io](https://github.com/jandelgado/golang-ci-template-github-actions/pkgs/container/golang-ci-template-github-actions).

To run goreleaser locally, start the tool with `gorelaser build --snapshot --clean`.

## Test coverage (coveralls)

We use the
[coveralls-github-action](https://github.com/coverallsapp/github-action) to
upload the golang coverage to coveralls.

Don't forget to enable `Leave comments (x)` in coveralls, under
`repo settings` > `pull request alerts`, so that the coveralls-action posts a comment
with the test coverage to affected pull requests:

![pr screenshot](images/pr.png)

## Author

(c) copyright 2021-2025 by Jan Delgado, License MIT