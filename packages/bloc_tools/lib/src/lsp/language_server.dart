import 'dart:io';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_tools/src/lsp/text_documents.dart';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:path/path.dart' as p;

/// {@template language_server}
/// The bloc language server which uses the language server protocol
/// to report diagnostics.
/// {@endtemplate}
class LanguageServer {
  /// {@macro language_server}
  LanguageServer({lsp.Connection? connection, Linter? linter})
    : _connection = connection ?? lsp.Connection(stdin, stdout),
      _linter = linter ?? const Linter();

  final lsp.Connection _connection;
  final Linter _linter;

  Uri? _root;

  void _reportDiagnostics({required Uri uri, String? content}) {
    final diagnostics = _linter.analyze(uri: uri, content: content);
    for (final entry in diagnostics.entries) {
      _connection.sendDiagnostics(
        lsp.PublishDiagnosticsParams(
          diagnostics: entry.value.map((d) => d.toLsp()).toList(),
          uri: p.toUri(entry.key),
        ),
      );
    }
  }

  /// Starts listening to the underlying connection.
  /// Returns a [Future] that will complete when the connection is closed or
  /// when it has an error. This method should not be called multiple times.
  Future<void> listen() async {
    _connection.onInitialize((params) async {
      _root = params.rootUri;
      return lsp.InitializeResult(
        capabilities: lsp.ServerCapabilities(
          textDocumentSync: const lsp.Either2.t1(
            lsp.TextDocumentSyncKind.Incremental,
          ),
        ),
      );
    });

    TextDocuments(
      _connection,
      onDidChangeContent: (params) async {
        _reportDiagnostics(
          uri: params.document.uri,
          content: params.document.getText(),
        );
      },
      onDidSave: (params) async {
        if (p.basename(params.document.uri.path) == 'analysis_options.yaml') {
          _reportDiagnostics(uri: File(params.document.uri.path).parent.uri);
        }
      },
    );

    _connection
      ..onInitialized((params) async {
        if (_root != null) _reportDiagnostics(uri: _root!);
      })
      ..onExit(_connection.close);

    await _connection.listen();
  }
}

extension on Diagnostic {
  lsp.Diagnostic toLsp() {
    return lsp.Diagnostic(
      message: message,
      code: code,
      source: source,
      codeDescription: lsp.CodeDescription(href: Uri.parse(description)),
      severity: lsp.DiagnosticSeverity.fromJson(severity.index + 1),
      range: lsp.Range(
        start: lsp.Position(
          character: range.start.character,
          line: range.start.line,
        ),
        end: lsp.Position(character: range.end.character, line: range.end.line),
      ),
    );
  }
}
