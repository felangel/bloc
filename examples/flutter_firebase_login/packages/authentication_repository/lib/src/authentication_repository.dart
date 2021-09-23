import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';


/// Thrown if during the sign up process if a failure occurs.
class SignUpWithEmailAndPasswordFailure implements Exception {
  final String message;
  SignUpWithEmailAndPasswordFailure(this.message);

  /// Create an authentication message from a firebase authentication exception code.
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch(code) {
      case 'invalid-email': return SignUpWithEmailAndPasswordFailure('Email is not valid or badly formatted.');
      case 'user-disabled': return SignUpWithEmailAndPasswordFailure('This user has been disabled. Please contact support for help.');
      case 'email-already-in-use' : return SignUpWithEmailAndPasswordFailure('An account already exists for that email.');
      case 'operation-not-allowed' : return SignUpWithEmailAndPasswordFailure('Operation is not allowed.  Please contact support.');
      case 'weak-password' : return SignUpWithEmailAndPasswordFailure('Please enter a stronger password.');
      default: return SignUpWithEmailAndPasswordFailure('An unknown exception occurred.');
    }
  }
}


/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
class LogInWithEmailAndPasswordFailure implements Exception {
  final String message;
  LogInWithEmailAndPasswordFailure(this.message);

  /// Create an authentication message from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch(code) {
      case 'invalid-email': return LogInWithEmailAndPasswordFailure('Email is not valid or badly formatted.');
      case 'user-disabled': return LogInWithEmailAndPasswordFailure('This user has been disabled. Please contact support for help.');
      case 'user-not-found': return LogInWithEmailAndPasswordFailure('Email is not found, please create an account.');
      case 'wrong-password': return LogInWithEmailAndPasswordFailure('Incorrect password, please try again.');
      default: return LogInWithEmailAndPasswordFailure('An unknown exception occurred.');
    }
  }
}

/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
class LogInWithGoogleFailure implements Exception {
  final String message;
  LogInWithGoogleFailure(this.message);

  /// Create an authentication message from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch(code) {
      case 'account-exists-with-different-credential': return LogInWithGoogleFailure('Account exists with different credentials.');
      case 'invalid-credential': return LogInWithGoogleFailure('The credential received is malformed or has expired.');
      case 'operation-not-allowed' : return LogInWithGoogleFailure('Operation is not allowed.  Please contact support.');
      case 'user-disabled': return LogInWithGoogleFailure('This user has been disabled. Please contact support for help.');
      case 'user-not-found': return LogInWithGoogleFailure('Email is not found, please create an account.');
      case 'wrong-password': return LogInWithGoogleFailure('Incorrect password, please try again.');
      case 'invalid-verification-code': return LogInWithGoogleFailure('The credential verification code received is invalid.');
      case 'invalid-verification-id': return LogInWithGoogleFailure('The credential verification ID received is invalid.');
      default: return LogInWithGoogleFailure('An unknown exception occurred.');
    }
  }
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Whether or not the current environment is web
  /// Should only be overriden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
        await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    }
  }


  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }

      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    }
  }



  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
