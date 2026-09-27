import 'package:common_github_search/common_github_search.dart';
import 'package:test/test.dart';

void main() {
  group('TextChanged', () {
    test('supports value equality via props', () {
      expect(
        const TextChanged(text: 'flutter'),
        const TextChanged(text: 'flutter'),
      );
      expect(
        const TextChanged(text: 'flutter'),
        isNot(const TextChanged(text: 'bloc')),
      );
    });

    test('toString includes the text', () {
      expect(
        const TextChanged(text: 'flutter').toString(),
        'TextChanged { text: flutter }',
      );
    });
  });

  group('NextPageRequested', () {
    test('supports value equality with empty props', () {
      expect(const NextPageRequested(), const NextPageRequested());
      expect(const NextPageRequested().props, isEmpty);
    });

    test('toString uses the default Equatable representation', () {
      expect(const NextPageRequested().toString(), 'NextPageRequested()');
    });
  });

  group('Refreshed', () {
    test('supports value equality with empty props', () {
      expect(const Refreshed(), const Refreshed());
      expect(const Refreshed().props, isEmpty);
    });

    test('toString uses the default Equatable representation', () {
      expect(const Refreshed().toString(), 'Refreshed()');
    });
  });
}
