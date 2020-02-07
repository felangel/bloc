#!/bin/bash

set -ex

cd $1

if grep -q 'build_runner:' "./pubspec.yaml"; then
    pub run build_runner build
fi

cd -
