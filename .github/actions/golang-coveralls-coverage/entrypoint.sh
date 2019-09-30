#!/bin/sh
set -eu
unset GOROOT
unset GOPATH

env
echo "IN=$INPUT_INFILE OUT=$INPUT_OUTFILE GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
cd $GITHUB_WORKSPACE
ls -l

echo "*******************************"

ls -l /go/bin/covfmt
/go/bin/covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"

ls -l $INPUT_INFILE || true
ls -l $INPUT_OUTFILE || true

echo "****INFILE****"
cat $INPUT_INFILE || true
echo "****OUTFILE****"
cat $INPUT_OUTFILE || true
