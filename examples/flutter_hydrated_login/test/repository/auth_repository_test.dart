import 'package:flutter_hydrated_login/models/user.dart';
import 'package:flutter_hydrated_login/repositorys/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

main() {
  MockAuthRepository _repo;
  User userMock;

  setUp(() {
    _repo = MockAuthRepository();
    userMock = User(
        email: 'loremipsum@gmail.com', password: 'Sayursop123', uuid: '123');
  });

  test('get uuid', () async {
    when(_repo.fetchUser(userMock.email, userMock.password))
        .thenAnswer((_) async => userMock);

    expect(await _repo.fetchUser(userMock.email, userMock.password), userMock);
  });

  test('get uuid error', () async {
    when(_repo.fetchUser(userMock.email, userMock.password)).thenThrow('oops');

    try {
      await _repo.fetchUser(userMock.email, userMock.password);
      throw('error');
    } catch (e) {
      expect(e, 'oops');
    }
  });
}
