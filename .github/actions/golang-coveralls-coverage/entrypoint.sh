#!/bin/sh
set -eu

env
echo "IN=$INPUT_INFILE OUT=$INPUT_OUTFILE GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
cd $GITHUB_WORKSPACE
ls -l

echo "*******************************"

echo /covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"
/covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"

ls -l $INPUT_INFILE || true
ls -l $INPUT_OUTFILE || true

cat $INPUT_INFILE || true
echo "*******************************"
cat $INPUT_OUTFILE || true
