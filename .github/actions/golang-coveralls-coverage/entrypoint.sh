#!/bin/sh
set -eu

unset GOROOT
unset GOPATH

cd $GITHUB_WORKSPACE
/go/bin/covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"
