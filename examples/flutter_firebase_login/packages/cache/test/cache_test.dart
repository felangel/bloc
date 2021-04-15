import 'package:cache/cache.dart';
import 'package:test/test.dart';

void main() {
  group('CacheClient', () {
    test('can write and read a value for a given key', () {
      final cache = CacheClient();
      final key = '__key__';
      final value = '__value__';
      expect(cache.read(key: key), isNull);
      cache.write(key: key, value: value);
      expect(cache.read(key: key), equals(value));
    });
  });
}
