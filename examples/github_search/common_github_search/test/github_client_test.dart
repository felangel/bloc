import 'dart:convert';

import 'package:common_github_search/common_github_search.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('GithubClient', () {
    late http.Client httpClient;
    late GithubClient client;

    const searchBody = '''
{
  "total_count": 1,
  "items": [
    {
      "full_name": "a/a",
      "html_url": "https://a",
      "owner": { "login": "octocat", "avatar_url": "https://avatar" }
    }
  ]
}
''';

    setUp(() {
      httpClient = MockHttpClient();
      client = GithubClient(httpClient: httpClient);
    });

    test(
      'search builds the URL with encoded term, page and per_page',
      () async {
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response(searchBody, 200));

        await client.search('flutter & dart', page: 3, perPage: 50);

        final captured =
            verify(() => httpClient.get(captureAny())).captured.single as Uri;
        expect(
          captured.toString(),
          'https://api.github.com/search/repositories?q='
          '${Uri.encodeQueryComponent('flutter & dart')}'
          '&page=3&per_page=50',
        );
      },
    );

    test('search uses default page 1 and per_page 30', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response(searchBody, 200));

      await client.search('flutter');

      final captured =
          verify(() => httpClient.get(captureAny())).captured.single as Uri;
      expect(captured.toString(), contains('&page=1&per_page=30'));
    });

    test('search returns a SearchResult on a 200 response', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response(searchBody, 200));

      final result = await client.search('flutter');

      expect(result.totalCount, 1);
      expect(result.items.single.fullName, 'a/a');
      expect(result.items.single.owner.login, 'octocat');
    });

    test('search throws SearchResultError on a non-200 response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          json.encode({'message': 'rate limited'}),
          403,
        ),
      );

      expect(
        () => client.search('flutter'),
        throwsA(
          isA<SearchResultError>().having(
            (e) => e.message,
            'message',
            'rate limited',
          ),
        ),
      );
    });

    test('close delegates to the underlying http client', () {
      when(() => httpClient.close()).thenReturn(null);

      client.close();

      verify(() => httpClient.close()).called(1);
    });

    test('defaults to a real http.Client when none is provided', () {
      // Exercises the `?? http.Client()` fallback. No request is made; the
      // default client is created and immediately closed.
      GithubClient().close();
    });
  });
}
