[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)

# flutter_firebase_login

Example Flutter app built with `flutter_bloc` to implement login using Firebase.

## Features

- Sign in with Google
- Sign up with email and password
- Sign in with email and password

## Getting Started

### Firebase

1. Create your project
2. Enable desired authentication options

### iOS

1. Replace `./ios/Runner/GoogleService-Info.plist` with your own
2. Update `./ios/Runner/info.plist`
   - Paste the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` to key `CFBundleURLSchemes` in `info.plist`

### Android

1. Replace `./android/app/google-services.json` with your own
2. Update `./android/app/build.gradle`
   - Replace `"com.example.flutter_firebase_login"` with the `package_name` from `google-services.json`

### Run the project

1. `flutter run`
