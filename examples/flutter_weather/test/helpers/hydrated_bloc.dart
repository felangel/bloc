import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';

class MockStorage extends Mock implements Storage {
  @override
  Future<void> write(String key, dynamic value) async {}
}

final hydratedStorage = MockStorage();

void initHydratedBloc() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = hydratedStorage;
}
