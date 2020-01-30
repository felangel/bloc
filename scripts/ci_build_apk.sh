#!/bin/bash

set -ex

source scripts/retry.sh

cd $1

flutter packages get
flutter build apk

cd -
