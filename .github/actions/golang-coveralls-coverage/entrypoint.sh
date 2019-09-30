#!/bin/sh
set -eu

cd $GITHUB_WORKSPACE
echo /covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"
/covfmt -infile "$INPUT_INFILE" -outfile "$INPUT_OUTFILE"

ls -l $INPUT_INFILE || true
ls -l $INPUT_OUTFILE || true

cat $INPUT_INFILE || true
echo "*******************************"
cat $INPUT_OUTFILE || true
