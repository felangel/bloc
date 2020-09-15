import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/app.dart';
import 'package:flutter_firebase_login/authentication/authentication.dart';
import 'package:flutter_firebase_login/home/home.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_firebase_login/splash/splash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore: must_be_immutable
class MockUser extends Mock implements User {
  @override
  String get id => 'id';

  @override
  String get name => 'Joe';

  @override
  String get email => 'joe@gmail.com';
}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockAuthenticationBloc extends MockBloc<AuthenticationState>
    implements AuthenticationBloc {}

void main() {
  group('App', () {
    AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(authenticationRepository.user).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    test('throws AssertionError when authenticationRepository is null', () {
      expect(() => App(authenticationRepository: null), throwsAssertionError);
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(authenticationRepository: authenticationRepository),
      );
      expect(find.byType(AppView), findsOneWidget);
    });
  });

  group('AppView', () {
    AuthenticationBloc authenticationBloc;
    AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationBloc = MockAuthenticationBloc();
      authenticationRepository = MockAuthenticationRepository();
    });

    testWidgets('renders SplashPage by default', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(value: authenticationBloc, child: AppView()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('navigates to LoginPage when status is unauthenticated',
        (tester) async {
      whenListen(
        authenticationBloc,
        Stream.value(const AuthenticationState.unauthenticated()),
      );
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: authenticationRepository,
          child: BlocProvider.value(
            value: authenticationBloc,
            child: AppView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('navigates to HomePage when status is authenticated',
        (tester) async {
      whenListen(
        authenticationBloc,
        Stream.value(AuthenticationState.authenticated(MockUser())),
      );
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: authenticationRepository,
          child: BlocProvider.value(
            value: authenticationBloc,
            child: AppView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
