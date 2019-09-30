#!/bin/sh

set -eu

pwd
ls -l $GITHUP_WORKSPACE

cd $GITHUB_WORKSPACE
/covfmt < coverage.out > coverage.lcov
