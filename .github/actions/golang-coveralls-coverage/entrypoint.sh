#!/bin/sh
set -eu

cd $GITHUB_WORKSPACE
/covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"
