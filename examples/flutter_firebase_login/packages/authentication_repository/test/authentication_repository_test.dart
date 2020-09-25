import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

const _mockFirebaseUserUid = 'mock-uid';
const _mockFirebaseUserEmail = 'mock-email';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {
  @override
  String get uid => _mockFirebaseUserUid;

  @override
  String get email => _mockFirebaseUserEmail;
}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': const <String, String>{},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return <String, dynamic>{
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': const <String, String>{},
      };
    }

    return null;
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  const email = 'test@gmail.com';
  const password = 't0ps3cret42';
  const user = User(
    id: _mockFirebaseUserUid,
    email: _mockFirebaseUserEmail,
    name: null,
    photo: null,
  );

  group('AuthenticationRepository', () {
    firebase_auth.FirebaseAuth firebaseAuth;
    GoogleSignIn googleSignIn;
    AuthenticationRepository authenticationRepository;

    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      googleSignIn = MockGoogleSignIn();
      authenticationRepository = AuthenticationRepository(
        firebaseAuth: firebaseAuth,
        googleSignIn: googleSignIn,
      );
    });

    test('creates FirebaseAuth instance internally when not injected', () {
      expect(() => AuthenticationRepository(), isNot(throwsException));
    });

    group('signUp', () {
      test('throws AssertionError when email is null', () {
        expect(
          () => authenticationRepository.signUp(
            email: null,
            password: password,
          ),
          throwsAssertionError,
        );
      });

      test('throws AssertionError when password is null', () {
        expect(
          () => authenticationRepository.signUp(
            email: email,
            password: null,
          ),
          throwsAssertionError,
        );
      });

      test('calls createUserWithEmailAndPassword', () async {
        await authenticationRepository.signUp(email: email, password: password);
        verify(firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('succeeds when createUserWithEmailAndPassword succeeds', () async {
        expect(
          authenticationRepository.signUp(email: email, password: password),
          completes,
        );
      });

      test('throws SignUpFailure when createUserWithEmailAndPassword throws',
          () async {
        when(firebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception());
        expect(
          authenticationRepository.signUp(email: email, password: password),
          throwsA(isA<SignUpFailure>()),
        );
      });
    });

    group('loginWithGoogle', () {
      const accessToken = 'access-token';
      const idToken = 'id-token';
      setUp(() {
        final googleSignInAuthentication = MockGoogleSignInAuthentication();
        final googleSignInAccount = MockGoogleSignInAccount();
        when(googleSignInAuthentication.accessToken).thenReturn(accessToken);
        when(googleSignInAuthentication.idToken).thenReturn(idToken);
        when(
          googleSignInAccount.authentication,
        ).thenAnswer((_) async => googleSignInAuthentication);
        when(
          googleSignIn.signIn(),
        ).thenAnswer((_) async => googleSignInAccount);
      });

      test('calls signIn authentication, and signInWithCredential', () async {
        await authenticationRepository.logInWithGoogle();
        verify(googleSignIn.signIn()).called(1);
        verify(firebaseAuth.signInWithCredential(any)).called(1);
      });

      test('succeeds when signIn succeeds', () {
        expect(authenticationRepository.logInWithGoogle(), completes);
      });

      test('throws LogInWithGoogleFailure when exception occurs', () async {
        when(firebaseAuth.signInWithCredential(any)).thenThrow(Exception());
        expect(
          authenticationRepository.logInWithGoogle(),
          throwsA(isA<LogInWithGoogleFailure>()),
        );
      });
    });

    group('logInWithEmailAndPassword', () {
      test('throws AssertionError when email is null', () {
        expect(
          () => authenticationRepository.logInWithEmailAndPassword(
            email: null,
            password: password,
          ),
          throwsAssertionError,
        );
      });

      test('throws AssertionError when password is null', () {
        expect(
          () => authenticationRepository.logInWithEmailAndPassword(
            email: email,
            password: null,
          ),
          throwsAssertionError,
        );
      });

      test('calls signInWithEmailAndPassword', () async {
        await authenticationRepository.logInWithEmailAndPassword(
          email: email,
          password: password,
        );
        verify(firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('succeeds when signInWithEmailAndPassword succeeds', () async {
        expect(
          authenticationRepository.logInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          completes,
        );
      });

      test(
          'throws LogInWithEmailAndPasswordFailure '
          'when signInWithEmailAndPassword throws', () async {
        when(firebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception());
        expect(
          authenticationRepository.logInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsA(isA<LogInWithEmailAndPasswordFailure>()),
        );
      });
    });

    group('logOut', () {
      test('calls signOut', () async {
        when(firebaseAuth.signOut()).thenAnswer((_) async => null);
        when(googleSignIn.signOut()).thenAnswer((_) async => null);
        await authenticationRepository.logOut();
        verify(firebaseAuth.signOut()).called(1);
        verify(googleSignIn.signOut()).called(1);
      });

      test('throws LogOutFailure when signOut throws', () async {
        when(firebaseAuth.signOut()).thenThrow(Exception());
        expect(
          authenticationRepository.logOut(),
          throwsA(isA<LogOutFailure>()),
        );
      });
    });

    group('user', () {
      test('emits User.empty when firebase user is null', () async {
        when(firebaseAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(null),
        );
        await expectLater(
          authenticationRepository.user,
          emitsInOrder(const <User>[User.empty]),
        );
      });

      test('emits User when firebase user is not null', () async {
        when(firebaseAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(MockFirebaseUser()),
        );
        await expectLater(
          authenticationRepository.user,
          emitsInOrder(const <User>[user]),
        );
      });
    });
  });
}
