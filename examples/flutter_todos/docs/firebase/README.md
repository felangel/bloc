# Flutter Todos Firebase

## Getting Started 🚀

This project contains 3 flavors:

- development
- staging
- production

## Firestore - Setup 😍

Using Firebase Firestore as the backend requires per-project setup.

### Install

```
firebase login
dart pub global activate flutterfire_cli
```

For more information follow the steps at https://firebase.google.com/docs/flutter/setup

### Configure

Based on the chosen flavor apply once the `flutterfire configure` command to integrate firebase into your project.

```sh
# Development
$ flutterfire configure -a 'com.example.verygoodcore.flutter_todos.dev' -i 'com.example.verygoodcore.flutter-todos.dev'

# Staging
$ flutterfire configure -a 'com.example.verygoodcore.flutter_todos.stg' -i 'com.example.verygoodcore.flutter-todos.stg'

# Production
$ flutterfire configure -a 'com.example.verygoodcore.flutter_todos' -i 'com.example.verygoodcore.flutter-todos'
```

## Getting Started 🚀

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart --dart-define=todos_api=firestore

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart --dart-define=todos_api=firestore

# Production
$ flutter run --flavor production --target lib/main_production.dart --dart-define=todos_api=firestore
```

_\*Flutter Todos works on iOS, Android, and Web._

---

## FAQ

Q: What does `flutterfire configure` changes in my project?

A: The command registers app bundles and fetchs credentails from Firebase API required to communicate with the service.
The credentials are writen locally into the project directories to be shipped with the app.

**VALID to commit changes**

```bash
$ git status
Changes not staged for commit:
        modified:   examples/flutter_todos/android/app/build.gradle
        modified:   examples/flutter_todos/android/build.gradle
```

```git
$ git diff
diff --git a/examples/flutter_todos/android/app/build.gradle b/examples/flutter_todos/android/app/build.gradle
--- a/examples/flutter_todos/android/app/build.gradle
+++ b/examples/flutter_todos/android/app/build.gradle
@@ -28,6 +28,9 @@ if (keystorePropertiesFile.exists()) {
 }

 apply plugin: 'com.android.application'
+// START: FlutterFire Configuration
+apply plugin: 'com.google.gms.google-services'
+// END: FlutterFire Configuration
 apply plugin: 'kotlin-android'
 apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

diff --git a/examples/flutter_todos/android/build.gradle b/examples/flutter_todos/android/build.gradle
index ba6fe4a4..4f69aab2 100644
--- a/examples/flutter_todos/android/build.gradle
+++ b/examples/flutter_todos/android/build.gradle
@@ -7,6 +7,9 @@ buildscript {

     dependencies {
         classpath 'com.android.tools.build:gradle:7.1.2'
+        // START: FlutterFire Configuration
+        classpath 'com.google.gms:google-services:4.3.10'
+        // END: FlutterFire Configuration
         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
     }
 }
```

**DO NOT Commit these changes**

⚠️ Note: For both security and flavored app considerations credential **should not** be committed into git repo.

```bash
$ git status
Untracked files:
        examples/flutter_todos/android/app/google-services.json
        examples/flutter_todos/ios/Runner/GoogleService-Info.plist
        examples/flutter_todos/ios/firebase_app_id_file.json
        examples/flutter_todos/lib/firebase_options.dart
```

_Use CI to integrate them into the artifact at runtime during the build phase of the app._
