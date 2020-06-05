#!/bin/bash
# inputs $1: project location

set -ex

source scripts/retry.sh

cd $1

if grep -q 'sdk: flutter' "./pubspec.yaml"; then
    flutter packages get
    flutter format --set-exit-if-changed lib
    flutter analyze --no-current-package lib

    if [[ -d "test" ]]; then
        flutter format --set-exit-if-changed test
        flutter analyze --no-current-package test
        flutter test --no-pub --coverage
    fi
elif grep -q 'angular:' "./pubspec.yaml"; then
    pub get
    dartfmt -w .
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?

    if [[ -d "test" ]]; then
        pub run build_runner test --fail-on-severe
    fi
else
    pub get
    dartfmt -w .
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?

    if [[ -d "test" ]]; then
        retry pub run test_coverage
    fi
fi

cd -
