import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

Position at({required int line, required int char}) {
  return Position(character: char, line: line);
}

Position position(int line, int char) => at(line: line, char: char);

Range range(int startLine, int startChar, int endLine, int endChar) {
  return Range(
    start: at(line: startLine, char: startChar),
    end: at(line: endLine, char: endChar),
  );
}

TextDocument createDocument(String content) {
  return TextDocument(uri: Uri.parse('test://hello/world'), content: content);
}

void main() {
  group(TextDocument, () {
    group('lines, offsets and positions', () {
      test('empty content', () {
        final document = createDocument('');
        expect(document.offsetAt(position(0, 0)), equals(0));
        final pos = document.positionAt(0);
        expect(pos.line, equals(0));
        expect(pos.character, equals(0));
      });

      test('single line', () {
        const content = 'Hello World';
        final document = createDocument(content);

        for (var i = 0; i < content.length; i++) {
          expect(document.offsetAt(position(0, i)), equals(i));

          final pos = document.positionAt(i);
          expect(pos.line, equals(0));
          expect(pos.character, equals(i));
        }
      });

      test('multiple lines', () {
        const content = 'abcde\nfghij\nklmno\n';
        final document = createDocument(content);

        for (var i = 0; i < content.length; i++) {
          final line = (i / 6).floor();
          final char = i % 6;
          expect(document.offsetAt(position(line, char)), equals(i));

          final pos = document.positionAt(i);
          expect(pos.line, equals(line));
          expect(pos.character, equals(char));
        }

        // Out of bounds.
        expect(document.offsetAt(position(3, 0)), content.length);
        expect(document.offsetAt(position(3, 1)), content.length);

        var pos = document.positionAt(18);
        expect(pos.line, equals(3));
        expect(pos.character, equals(0));

        pos = document.positionAt(19);
        expect(pos.line, equals(3));
        expect(pos.character, equals(0));
      });

      test('getText', () {
        const content = 'abcde\nfghij\nklmno';
        final document = createDocument(content);
        expect(document.getText(), equals(content));

        expect(document.getText(range: range(0, 0, 0, 5)), equals('abcde'));
        expect(document.getText(range: range(0, 4, 1, 1)), equals('e\nf'));
      });

      test('invalid input at beginning of file', () {
        final document = createDocument('asdf');
        expect(document.offsetAt(position(-1, 0)), 0);
        expect(document.offsetAt(position(0, -1)), 0);

        final pos = document.positionAt(-1);
        expect(pos.line, equals(0));
        expect(pos.character, equals(0));
      });

      test('invalid input at end of file', () {
        final document = createDocument('asdf');
        expect(document.offsetAt(position(1, 1)), 4);

        final pos = document.positionAt(8);
        expect(pos.line, equals(0));
        expect(pos.character, equals(4));
      });

      test('invalid input at beginning of line', () {
        final document = createDocument('a\ns\nd\r\nf');
        expect(document.offsetAt(position(0, -1)), 0);
        expect(document.offsetAt(position(1, -1)), 2);
        expect(document.offsetAt(position(2, -1)), 4);
        expect(document.offsetAt(position(3, -1)), 7);
      });

      test('invalid input at end of line', () {
        final document = createDocument('a\ns\nd\r\nf');
        expect(document.offsetAt(position(0, 10)), 1);
        expect(document.offsetAt(position(1, 10)), 3);
        expect(document.offsetAt(position(2, 2)), 5);
        expect(document.offsetAt(position(2, 3)), 5);
        expect(document.offsetAt(position(2, 10)), 5);
        expect(document.offsetAt(position(3, 10)), 8);

        final pos = document.positionAt(6);
        expect(pos.line, equals(2));
        expect(pos.character, equals(1));
      });
    });
  });

  group(TextDocumentType, () {
    test('detects file types', () {
      final blocFile = TextDocument(
        uri: Uri.parse('counter_bloc.dart'),
        content: '',
      );
      expect(blocFile.type, equals(TextDocumentType.bloc));
      expect(blocFile.type.isBloc, isTrue);
      expect(blocFile.type.isCubit, isFalse);
      expect(blocFile.type.isOther, isFalse);

      final cubitFile = TextDocument(
        uri: Uri.parse('counter_cubit.dart'),
        content: '',
      );
      expect(cubitFile.type, equals(TextDocumentType.cubit));
      expect(cubitFile.type.isBloc, isFalse);
      expect(cubitFile.type.isCubit, isTrue);
      expect(cubitFile.type.isOther, isFalse);

      final otherFile = TextDocument(uri: Uri.parse('main.dart'), content: '');
      expect(otherFile.type, equals(TextDocumentType.other));
      expect(otherFile.type.isBloc, isFalse);
      expect(otherFile.type.isCubit, isFalse);
      expect(otherFile.type.isOther, isTrue);
    });
  });
}
