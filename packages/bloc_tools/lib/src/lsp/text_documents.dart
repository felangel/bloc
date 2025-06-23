// ignore_for_file: public_member_api_docs

import 'package:bloc_tools/src/lsp/text_document.dart';
import 'package:lsp_server/lsp_server.dart';

class TextDocumentChangeEvent {
  const TextDocumentChangeEvent(this.document);
  final TextDocument document;
}

/// A simplified, Dart representation of VSCode's Language Server
/// [TextDocuments](https://github.com/microsoft/vscode-languageserver-node/blob/main/server/src/common/textDocuments.ts)
class TextDocuments {
  TextDocuments(
    Connection connection, {
    Future<void> Function(TextDocumentChangeEvent)? onDidChangeContent,
    Future<void> Function(TextDocumentChangeEvent)? onDidSave,
  }) {
    connection
      ..onDidOpenTextDocument((event) async {
        final document = TextDocument(
          event.textDocument.uri,
          event.textDocument.languageId,
          event.textDocument.version,
          event.textDocument.text,
        );
        _syncedDocuments[document.uri] = document;

        if (onDidChangeContent != null) {
          await onDidChangeContent(TextDocumentChangeEvent(document));
        }
      })
      ..onDidChangeTextDocument((event) async {
        final document = event.textDocument;
        final changes = event.contentChanges;
        if (changes.isEmpty) return;

        final version = document.version;
        final syncedDocument = get(document.uri);
        if (syncedDocument == null) return;

        syncedDocument.update(changes, version);

        if (onDidChangeContent != null) {
          await onDidChangeContent(TextDocumentChangeEvent(syncedDocument));
        }
      })
      ..onDidSaveTextDocument((event) async {
        final document = _syncedDocuments[event.textDocument.uri];
        if (document != null && onDidSave != null) {
          await onDidSave(TextDocumentChangeEvent(document));
        }
      });
  }

  final Map<Uri, TextDocument> _syncedDocuments = {};

  /// Get a synced [TextDocument] for the provided [uri].
  /// Returns `null` is none exists.
  TextDocument? get(Uri uri) => _syncedDocuments[uri];
}
