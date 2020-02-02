#!/bin/bash

set -ex

source scripts/retry.sh

cd $1

grep -q 'build_runner:' "./pubspec.yaml"; then
    pub run build_runner build
fi

cd -
