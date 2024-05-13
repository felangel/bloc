import { TextEditor, Selection, Position } from "vscode";

const openBracket = "(";
const closeBracket = ")";

export const getSelectedText = (editor: TextEditor): Selection => {
  const emptySelection = new Selection(
    editor.document.positionAt(0),
    editor.document.positionAt(0)
  );
  const language = editor.document.languageId;
  if (language != "dart") return emptySelection;

  const line = editor.document.lineAt(editor.selection.start);
  const lineText = line.text;
  const openBracketIndex = line.text.indexOf(
    openBracket,
    editor.selection.anchor.character
  );

  let widgetStartIndex =
    openBracketIndex > 1
      ? openBracketIndex - 1
      : editor.selection.anchor.character;
  for (widgetStartIndex; widgetStartIndex > 0; widgetStartIndex--) {
    const currentChar = lineText.charAt(widgetStartIndex);
    const isBeginningOfWidget =
      currentChar === openBracket ||
      (currentChar === " " &&
        lineText.charAt(widgetStartIndex - 1) !== "," &&
        lineText.substring(widgetStartIndex - 5, widgetStartIndex) != "const");
    if (isBeginningOfWidget) break;
  }
  widgetStartIndex++;

  if (openBracketIndex < 0) {
    const commaIndex = lineText.indexOf(",", widgetStartIndex);
    const bracketIndex = lineText.indexOf(closeBracket, widgetStartIndex);
    const endIndex =
      commaIndex >= 0
        ? commaIndex
        : bracketIndex >= 0
        ? bracketIndex
        : lineText.length;

    return new Selection(
      new Position(line.lineNumber, widgetStartIndex),
      new Position(line.lineNumber, endIndex)
    );
  }

  let bracketCount = 1;
  for (let l = line.lineNumber; l < editor.document.lineCount; l++) {
    const currentLine = editor.document.lineAt(l);
    let c = l === line.lineNumber ? openBracketIndex + 1 : 0;
    for (c; c < currentLine.text.length; c++) {
      const currentChar = currentLine.text.charAt(c);
      if (currentChar === openBracket) bracketCount++;
      if (currentChar === closeBracket) bracketCount--;
      if (bracketCount === 0) {
        return new Selection(
          new Position(line.lineNumber, widgetStartIndex),
          new Position(l, c + 1)
        );
      }
    }
  }

  return emptySelection;
};
