#!/bin/sh

set -eu

pwd
ls -l $GITHUP_WORKSPACE

cd $GITHUB_WORKSPACE
/app < coverage.out > coverage.lcov
