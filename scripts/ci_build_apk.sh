#!/bin/bash

set -ex

cd $1

if [[ -f "android/app/example_google-services.json" ]]; then
    cp android/app/example_google-services.json android/app/google-services.json
fi
flutter packages get
if [[ -f "lib/main.dart" ]]; then
    flutter build apk
fi

cd -
