#!/bin/bash
# inputs $1: project location
# inputs $2: how to build the app ('apk' or 'ios')

set -ex

cd $1

if [ $2 = 'apk' ]; then
    if [[ -f "android/app/example_google-services.json" ]]; then
        cp android/app/example_google-services.json android/app/google-services.json
    fi
elif [ $2 = 'ios' ]; then
    # TODO: Firebase setup for iOS
fi

flutter packages get
if [[ -f "lib/main.dart" ]]; then
    flutter build $2
fi

cd -
