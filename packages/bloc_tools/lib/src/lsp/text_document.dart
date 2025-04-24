import 'dart:math';

import 'package:lsp_server/lsp_server.dart';

/// The newline symbol (\n).
const lineFeed = 10;

/// The carriage return symbol (\r).
const carriageReturn = 13;

/// {@template text_document}
/// A simplified, Dart representation of VSCode's Language Server
/// [TextDocument](https://github.com/microsoft/vscode-languageserver-node/blob/main/textDocument/src/main.ts).
/// {@endtemplate}
class TextDocument {
  /// {@macro text_document}
  TextDocument(this._uri, this._languageId, this._version, this._content);

  final Uri _uri;
  final String _languageId;
  int _version;
  String _content;
  List<int>? _lineOffsets;

  /// The associated URI for this document. Most documents have the file scheme,
  /// indicating that they represent files on disk. However, some documents may
  /// have other schemes indicating that they are not available on disk.
  Uri get uri => _uri;

  /// The identifier of the language associated with this document.
  String get languageId => _languageId;

  /// The version number of this document (it will increase after each change,
  /// including undo/redo).
  int get version => _version;

  /// The number of lines in this document.
  int get lineCount => _getLineOffsets().length;

  /// Get the text of this document. Provide a [Range] to get a substring.
  String getText({Range? range}) {
    if (range != null) {
      final start = offsetAt(range.start);
      final end = offsetAt(range.end);
      return _content.substring(start, end);
    }
    return _content;
  }

  /// Convert a [Position] to a zero-based offset.
  int offsetAt(Position position) {
    final lineOffsets = _getLineOffsets();
    if (position.line >= lineOffsets.length) {
      return _content.length;
    } else if (position.line < 0) {
      return 0;
    }

    final lineOffset = lineOffsets[position.line];
    if (position.character <= 0) {
      return lineOffset;
    }

    final nextLineOffset =
        (position.line + 1 < lineOffsets.length)
            ? lineOffsets[position.line + 1]
            : _content.length;
    final offset = min(lineOffset + position.character, nextLineOffset);

    return _ensureBeforeEndOfLine(offset: offset, lineOffset: lineOffset);
  }

  /// Converts a zero-based offset to a [Position].
  Position positionAt(int offset) {
    // ignore: parameter_assignments
    offset = max(min(offset, _content.length), 0);
    final lineOffsets = _getLineOffsets();
    var low = 0;
    var high = lineOffsets.length;
    if (high == 0) return Position(character: offset, line: 0);

    while (low < high) {
      final mid = ((low + high) / 2).floor();
      if (lineOffsets[mid] > offset) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }

    final line = low - 1;
    // ignore: parameter_assignments
    offset = _ensureBeforeEndOfLine(
      offset: offset,
      lineOffset: lineOffsets[line],
    );

    return Position(character: offset - lineOffsets[line], line: line);
  }

  /// Updates this text document by modifying its content.
  void update(List<TextDocumentContentChangeEvent> changes, int version) {
    _version = version;
    for (final c in changes) {
      final change = c.map((v) => v, (v) => v);
      if (change is TextDocumentContentChangeEvent1) {
        // Incremental sync.
        final range = getWellformedRange(change.range);
        final text = change.text;

        final startOffset = offsetAt(range.start);
        final endOffset = offsetAt(range.end);

        // Update content.
        _content =
            _content.substring(0, startOffset) +
            text +
            _content.substring(endOffset, _content.length);

        // Update offsets without recomputing for the whole document.
        final startLine = max(range.start.line, 0);
        final endLine = max(range.end.line, 0);
        final lineOffsets = _lineOffsets!;
        final addedLineOffsets = _computeLineOffsets(
          text,
          isAtLineStart: false,
          textOffset: startOffset,
        );

        if (endLine - startLine == addedLineOffsets.length) {
          for (var i = 0, len = addedLineOffsets.length; i < len; i++) {
            lineOffsets[i + startLine + 1] = addedLineOffsets[i];
          }
        } else {
          // Avoid going outside the range on weird range inputs.
          lineOffsets.replaceRange(
            min(startLine + 1, lineOffsets.length),
            min(endLine + 1, lineOffsets.length),
            addedLineOffsets,
          );
        }

        final diff = text.length - (endOffset - startOffset);
        if (diff != 0) {
          for (
            var i = startLine + 1 + addedLineOffsets.length,
                len = lineOffsets.length;
            i < len;
            i++
          ) {
            lineOffsets[i] = lineOffsets[i] + diff;
          }
        }
      } else if (change is TextDocumentContentChangeEvent2) {
        // Full sync.
        _content = change.text;
        _lineOffsets = null;
      }
    }
  }

  List<int> _getLineOffsets() {
    _lineOffsets ??= _computeLineOffsets(_content, isAtLineStart: true);
    return _lineOffsets!;
  }

  List<int> _computeLineOffsets(
    String content, {
    required bool isAtLineStart,
    int textOffset = 0,
  }) {
    final result = isAtLineStart ? [textOffset] : <int>[];

    for (var i = 0; i < content.length; i++) {
      final char = content.codeUnitAt(i);
      if (_isEndOfLine(char)) {
        if (char == carriageReturn) {
          final nextCharIsLineFeed =
              i + 1 < content.length && content.codeUnitAt(i + 1) == lineFeed;
          if (nextCharIsLineFeed) {
            i++;
          }
        }
        result.add(textOffset + i + 1);
      }
    }

    return result;
  }

  bool _isEndOfLine(int char) {
    return char == lineFeed || char == carriageReturn;
  }

  int _ensureBeforeEndOfLine({required int offset, required int lineOffset}) {
    while (offset > lineOffset &&
        _isEndOfLine(_content.codeUnitAt(offset - 1))) {
      offset--;
    }
    return offset;
  }

  /// Returns a wellformed range from the provided [range].
  Range getWellformedRange(Range range) {
    final start = range.start;
    final end = range.end;
    final isStartLineAfterEndLine = start.line > end.line;
    final isStartCharAfterEndChar =
        start.line == end.line && start.character > end.character;
    final shouldSwap = isStartLineAfterEndLine || isStartCharAfterEndChar;
    if (shouldSwap) return Range(start: end, end: start);
    return range;
  }
}
