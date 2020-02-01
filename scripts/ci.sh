#!/bin/bash

set -ex

source scripts/retry.sh

cd $1
package=${PWD##*/}

if grep -q 'sdk: flutter' "./pubspec.yaml"; then
    flutter packages get
    flutter format --set-exit-if-changed lib
    flutter analyze --no-current-package lib
    if [[ -f "$package/test" ]]; then
      flutter format --set-exit-if-changed test
      flutter analyze --no-current-package test
      flutter test --no-pub --coverage
      cp ./coverage/lcov.info ../../$package.lcov
    fi
elif grep -q 'angular:' "./pubspec.yaml"; then
    pub get
    dartfmt -w .
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?
    pub run build_runner test --fail-on-severe
else
    pub get
    dartfmt -w .
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?
    retry pub run test_coverage
    cp ./coverage/lcov.info ../../$package.lcov
fi

cd -
