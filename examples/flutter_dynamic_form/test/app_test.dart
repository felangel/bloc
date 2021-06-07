import 'package:flutter_dynamic_form/app.dart';
import 'package:flutter_dynamic_form/new_car/new_car.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNewCarRepository extends Mock implements NewCarRepository {}

void main() {
  group('MyApp', () {
    late NewCarRepository newCarRepository;

    setUp(() {
      newCarRepository = MockNewCarRepository();
    });

    testWidgets('renders NewCarPage', (tester) async {
      when(() => newCarRepository.fetchBrands()).thenAnswer(
        (_) async => ['honda'],
      );
      await tester.pumpWidget(MyApp(newCarRepository: newCarRepository));
      expect(find.byType(NewCarPage), findsOneWidget);
    });
  });
}
