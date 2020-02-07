#!/bin/bash
# inputs $1: project location

set -ex

source scripts/retry.sh

cd $1
folder=${PWD##*/}

if grep -q 'sdk: flutter' "./pubspec.yaml"; then
    flutter packages get
    if [[ -d "$folder/lib" ]]; then
        flutter format --set-exit-if-changed lib
        flutter analyze --no-current-package lib
    fi
    if [[ -d "$folder/test" ]]; then
        flutter format --set-exit-if-changed test
        flutter analyze --no-current-package test
        flutter test --no-pub --coverage
        cp ./coverage/lcov.info ../../$folder.lcov
    fi
    if [[ -d "$folder/test_driver" ]]; then
        flutter format --set-exit-if-changed test_driver
        flutter analyze --no-current-package test_driver
    fi
elif grep -q 'angular:' "./pubspec.yaml"; then
    pub get
    dartfmt -w .
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?
    if [[ -d "$folder/test" ]]; then
        pub run build_runner test --fail-on-severe
    fi
else
    pub get
    dartfmt -w .
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?
    if [[ -d "$folder/test" ]]; then
        retry pub run test_coverage
        cp ./coverage/lcov.info ../../$folder.lcov
    fi
fi

cd -
