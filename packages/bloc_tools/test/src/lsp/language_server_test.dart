// ignore_for_file: avoid_private_typedef_functions

import 'dart:async';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_tools/src/lsp/language_server.dart';
import 'package:lsp_server_ce/lsp_server_ce.dart'
    hide Diagnostic, Position, Range;
import 'package:lsp_server_ce/lsp_server_ce.dart' as lsp;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class _MockLinter extends Mock implements Linter {}

class _MockConnection extends Mock implements Connection {}

class _FakePublishDiagnosticsParams extends Fake
    implements PublishDiagnosticsParams {}

typedef _OnInitializeHandler =
    Future<InitializeResult> Function(InitializeParams);

typedef _OnInitializedHandler = Future<dynamic> Function(InitializedParams);

typedef _OnDidOpenTextDocumentHandler =
    Future<dynamic> Function(DidOpenTextDocumentParams);

typedef _OnDidChangeTextDocumentHandler =
    Future<dynamic> Function(DidChangeTextDocumentParams);

typedef _OnDidSaveTextDocumentHandler =
    Future<dynamic> Function(DidSaveTextDocumentParams);

void main() {
  group(LanguageServer, () {
    final rootUri = Uri.parse('file:///c:/users/dash/main.dart');
    late Connection connection;
    late Linter linter;
    late LanguageServer languageServer;

    setUpAll(() {
      registerFallbackValue(_FakePublishDiagnosticsParams());
      registerFallbackValue(Uri());
    });

    setUp(() {
      connection = _MockConnection();
      linter = _MockLinter();
      languageServer = LanguageServer(connection: connection, linter: linter);
    });

    test('can be instantiated with default args', () {
      expect(LanguageServer.new, returnsNormally);
    });

    group('listen', () {
      setUp(() {
        when(() => connection.listen()).thenAnswer((_) async {});
        when(() => connection.close()).thenAnswer((_) async {});

        const diagnostic = Diagnostic(
          range: Range(
            start: Position(line: 1, character: 1),
            end: Position(line: 1, character: 42),
          ),
          code: 'code',
          description: 'https://flutter.dev',
          message: 'message',
          severity: Severity.warning,
          source: 'source',
          hint: 'hint',
        );

        when(
          () => linter.analyze(
            uri: any(named: 'uri'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((invocation) {
          final uri = invocation.namedArguments[#uri] as Uri;
          return <String, List<Diagnostic>>{
            p.fromUri(uri): [diagnostic],
          };
        });
      });

      test('onInitialize returns correct result', () async {
        unawaited(languageServer.listen());
        final handler =
            verify(() => connection.onInitialize(captureAny())).captured.single
                as _OnInitializeHandler;

        final params = InitializeParams(
          capabilities: ClientCapabilities(),
          rootUri: rootUri,
        );

        await expectLater(
          handler(params),
          completion(
            isA<InitializeResult>().having(
              (r) => r.capabilities,
              'capabilites',
              isA<ServerCapabilities>().having(
                (c) => c.textDocumentSync,
                'textDocumentSync',
                equals(
                  const Either2<
                    TextDocumentSyncKind,
                    TextDocumentSyncOptions
                  >.t1(TextDocumentSyncKind.Incremental),
                ),
              ),
            ),
          ),
        );
      });

      test('onInitialized does nothing when rootUri is null', () async {
        unawaited(languageServer.listen());
        final handler =
            verify(() => connection.onInitialized(captureAny())).captured.single
                as _OnInitializedHandler;
        await expectLater(handler(InitializedParams()), completes);
        verifyNever(() => connection.sendDiagnostics(any()));
      });

      test('onInitialized reports diagnostics for rootUri', () async {
        unawaited(languageServer.listen());
        final onInitializeHandler =
            verify(() => connection.onInitialize(captureAny())).captured.single
                as _OnInitializeHandler;

        await expectLater(
          onInitializeHandler(
            InitializeParams(
              capabilities: ClientCapabilities(),
              rootUri: rootUri,
            ),
          ),
          completes,
        );

        final onInitializedHandler =
            verify(() => connection.onInitialized(captureAny())).captured.single
                as _OnInitializedHandler;
        await expectLater(onInitializedHandler(InitializedParams()), completes);
        verify(
          () => connection.sendDiagnostics(
            any(
              that: isA<PublishDiagnosticsParams>()
                  .having((p) => p.uri, 'uri', p.toUri(p.fromUri(rootUri)))
                  .having((p) => p.diagnostics, 'diagnostics', [
                    lsp.Diagnostic(
                      range: lsp.Range(
                        start: lsp.Position(line: 1, character: 1),
                        end: lsp.Position(line: 1, character: 42),
                      ),
                      code: 'code',
                      codeDescription: lsp.CodeDescription(
                        href: Uri.parse('https://flutter.dev'),
                      ),
                      message: 'message',
                      severity: DiagnosticSeverity.Warning,
                      source: 'source',
                    ),
                  ]),
            ),
          ),
        ).called(1);
      });

      test('onDidChangeContent reports diagnostics', () async {
        unawaited(languageServer.listen());
        final onDidOpenTextDocumentHandler =
            verify(
                  () => connection.onDidOpenTextDocument(captureAny()),
                ).captured.single
                as _OnDidOpenTextDocumentHandler;
        final didOpenTextDocumentParams = DidOpenTextDocumentParams(
          textDocument: TextDocumentItem(
            languageId: 'dart',
            text: 'void main() {}',
            uri: p.toUri(p.fromUri(rootUri)),
            version: 1,
          ),
        );

        await onDidOpenTextDocumentHandler(didOpenTextDocumentParams);

        verify(
          () => connection.sendDiagnostics(
            any(
              that: isA<PublishDiagnosticsParams>()
                  .having(
                    (p) => p.uri,
                    'uri',
                    didOpenTextDocumentParams.textDocument.uri,
                  )
                  .having((p) => p.diagnostics, 'diagnostics', [
                    lsp.Diagnostic(
                      range: lsp.Range(
                        start: lsp.Position(line: 1, character: 1),
                        end: lsp.Position(line: 1, character: 42),
                      ),
                      code: 'code',
                      codeDescription: lsp.CodeDescription(
                        href: Uri.parse('https://flutter.dev'),
                      ),
                      message: 'message',
                      severity: DiagnosticSeverity.Warning,
                      source: 'source',
                    ),
                  ]),
            ),
          ),
        ).called(1);

        final onDidChangeTextDocumentHandler =
            verify(
                  () => connection.onDidChangeTextDocument(captureAny()),
                ).captured.single
                as _OnDidChangeTextDocumentHandler;
        final didChangeTextDocumentParams = DidChangeTextDocumentParams(
          textDocument: VersionedTextDocumentIdentifier(
            uri: p.toUri(p.fromUri(rootUri)),
            version: 1,
          ),
          contentChanges: [
            lsp.Either2<
              TextDocumentContentChangeEvent1,
              TextDocumentContentChangeEvent2
            >.t2(
              TextDocumentContentChangeEvent2(
                text: 'void main() => print("hello");',
              ),
            ),
          ],
        );

        await onDidChangeTextDocumentHandler(didChangeTextDocumentParams);
        verify(() => connection.sendDiagnostics(any())).called(1);
      });

      test(
        'onDidSave does nothing when file is not analysis_options.yaml',
        () async {
          unawaited(languageServer.listen());
          final onDidOpenTextDocumentHandler =
              verify(
                    () => connection.onDidOpenTextDocument(captureAny()),
                  ).captured.single
                  as _OnDidOpenTextDocumentHandler;
          final didOpenParams = DidOpenTextDocumentParams(
            textDocument: TextDocumentItem(
              languageId: 'dart',
              text: 'void main() {}',
              uri: Uri.parse('file://main.dart'),
              version: 1,
            ),
          );

          await onDidOpenTextDocumentHandler(didOpenParams);
          verify(() => connection.sendDiagnostics(any())).called(1);

          final onDidSaveTextDocumentHandler =
              verify(
                    () => connection.onDidSaveTextDocument(captureAny()),
                  ).captured.single
                  as _OnDidSaveTextDocumentHandler;
          final didSaveParams = DidSaveTextDocumentParams(
            textDocument: TextDocumentIdentifier(
              uri: didOpenParams.textDocument.uri,
            ),
          );

          await onDidSaveTextDocumentHandler(didSaveParams);

          verifyNever(() => connection.sendDiagnostics(any()));
        },
      );

      test('onDidSave reports diagnostics in parent dir '
          'when file is analysis_options.yaml', () async {
        unawaited(languageServer.listen());
        final onDidOpenTextDocumentHandler =
            verify(
                  () => connection.onDidOpenTextDocument(captureAny()),
                ).captured.single
                as _OnDidOpenTextDocumentHandler;
        final didOpenParams = DidOpenTextDocumentParams(
          textDocument: TextDocumentItem(
            languageId: 'yaml',
            text: 'include: "package:bloc_lint/recommended.yaml";',
            uri: Uri.parse('file://foo/analysis_options.yaml'),
            version: 1,
          ),
        );

        await onDidOpenTextDocumentHandler(didOpenParams);
        verify(() => connection.sendDiagnostics(any())).called(1);

        final onDidSaveTextDocumentHandler =
            verify(
                  () => connection.onDidSaveTextDocument(captureAny()),
                ).captured.single
                as _OnDidSaveTextDocumentHandler;
        final didSaveParams = DidSaveTextDocumentParams(
          textDocument: TextDocumentIdentifier(
            uri: didOpenParams.textDocument.uri,
          ),
        );

        await onDidSaveTextDocumentHandler(didSaveParams);

        verify(() => connection.sendDiagnostics(any())).called(1);
      });

      test('onExit closes the connection', () async {
        unawaited(languageServer.listen());
        final onExitHandler =
            verify(() => connection.onExit(captureAny())).captured.single
                as Future<dynamic> Function();
        await expectLater(onExitHandler(), completes);
        verify(() => connection.close()).called(1);
      });
    });
  });
}
