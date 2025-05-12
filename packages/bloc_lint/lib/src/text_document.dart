import 'dart:math';

import 'package:path/path.dart' as p;

/// The newline symbol (\n).
const newline = 10;

/// The carriage return symbol (\r).
const carriageReturn = 13;

/// {@template text_document}
/// A simplified, Dart representation of VSCode's Language Server
/// [TextDocument](https://github.com/microsoft/vscode-languageserver-node/blob/main/textDocument/src/main.ts).
/// {@endtemplate}
class TextDocument {
  /// {@macro text_document}
  TextDocument({required Uri uri, required String content})
    : _uri = uri,
      _content = content;

  static final _ignoreForFileRegExp = RegExp(
    r'^//\s*ignore_for_file:(.*?)$',
    dotAll: true,
    multiLine: true,
  );

  static final _ignoreForLineRegExp = RegExp(r'^//\s*ignore:(.*)$');

  final Uri _uri;
  final String _content;
  List<int>? _lineOffsets;

  /// The associated URI for this document. Most documents have the file scheme,
  /// indicating that they represent files on disk. However, some documents may
  /// have other schemes indicating that they are not available on disk.
  Uri get uri => _uri;

  /// Whether the line for the current range contains an // ignore: for the given rule.
  Set<String> ignoreForLine({required Range range}) {
    return {
      ..._ignoresAboveLine(range: range),
      ..._ignoresAfterLine(range: range),
    };
  }

  Set<String> _ignoresAboveLine({required Range range}) {
    final previousLine = range.start.line - 1;
    if (previousLine < 0) return const <String>{};
    final line = getText(
      range: Range(
        start: Position(character: 0, line: previousLine),
        end: Position(character: _content.length, line: previousLine),
      ),
    );
    return _lineIgnores(line);
  }

  Set<String> _ignoresAfterLine({required Range range}) {
    final afterText = getText(
      range: Range(
        start: Position(character: range.end.character, line: range.end.line),
        end: Position(character: _content.length, line: range.end.line),
      ),
    );
    final index = afterText.indexOf('// ignore:');
    if (index == -1) return const <String>{};
    final line = afterText.substring(index);
    return _lineIgnores(line);
  }

  Set<String> _lineIgnores(String line) {
    final result = <String>{};
    final matches = _ignoreForLineRegExp.allMatches(line);
    if (matches.isEmpty) return result;
    for (final match in matches) {
      final contents = match.group(1);
      if (contents == null) continue;
      result.addAll(contents.split(',').map((segment) => segment.trim()));
    }
    return result;
  }

  /// Returns a list of rules ignored for the current file.
  /// e.g. // ignore_for_file: avoid_flutter_imports, prefer_bloc
  Set<String> get ignoreForFile {
    final result = <String>{};
    final matches = _ignoreForFileRegExp.allMatches(_content);
    if (matches.isEmpty) return result;
    for (final match in matches) {
      final contents = match.group(1);
      if (contents == null) continue;
      result.addAll(contents.split(',').map((segment) => segment.trim()));
    }
    return result;
  }

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
          final nextCharIsnewline =
              i + 1 < content.length && content.codeUnitAt(i + 1) == newline;
          if (nextCharIsnewline) {
            i++;
          }
        }
        result.add(textOffset + i + 1);
      }
    }

    return result;
  }

  bool _isEndOfLine(int char) => char == newline || char == carriageReturn;

  int _ensureBeforeEndOfLine({required int offset, required int lineOffset}) {
    while (offset > lineOffset &&
        _isEndOfLine(_content.codeUnitAt(offset - 1))) {
      offset--;
    }
    return offset;
  }
}

/// {@template position}
/// A specific position within a [TextDocument].
/// {@endtemplate}
class Position {
  /// {@macro position}
  const Position({required this.line, required this.character});

  /// The line number.
  final int line;

  /// The character offset within the line.
  final int character;

  /// Converts a [Position] into a [Map].
  Map<String, dynamic> toJson() => {'line': line, 'character': character};
}

/// {@template range}
/// A range of content within a [TextDocument].
/// {@endtemplate}
class Range {
  /// {@macro range}
  const Range({required this.start, required this.end});

  /// The starting position.
  final Position start;

  /// The ending position.
  final Position end;

  /// Converts a [Range] to a [Map].
  Map<String, dynamic> toJson() {
    return {'start': start.toJson(), 'end': end.toJson()};
  }
}

/// Relevant types of text documents.
enum TextDocumentType {
  /// A bloc file.
  bloc,

  /// A cubit file.
  cubit,

  /// Any other file.
  other,
}

/// Extensions on [TextDocument] that provide access to
/// document type information.
extension TextDocumentX on TextDocument {
  /// Returns the [TextDocumentType] for the given document.
  TextDocumentType get type {
    final basename = p.basename(uri.path);
    return basename.endsWith('_bloc.dart')
        ? TextDocumentType.bloc
        : basename.endsWith('_cubit.dart')
        ? TextDocumentType.cubit
        : TextDocumentType.other;
  }
}

/// Extensions on [TextDocumentType] that provide access to
/// convenience methods for interpreting the type.
extension TextDocumentTypeX on TextDocumentType {
  /// Whether the document type is a bloc.
  bool get isBloc => this == TextDocumentType.bloc;

  /// Whether the document type is a cubit.
  bool get isCubit => this == TextDocumentType.cubit;

  /// Whether the document type is other.
  bool get isOther => this == TextDocumentType.other;
}
