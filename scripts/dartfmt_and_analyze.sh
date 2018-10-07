#!/bin/bash

set -e

flutter packages get || exit $

EXIT_CODE=0
dartfmt -w .
dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?

exit $EXIT_CODE