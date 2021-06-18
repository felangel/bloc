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
    "(",
    editor.selection.anchor.character
  );

  if (openBracketIndex < 0) return emptySelection;

  let widgetStartIndex = openBracketIndex - 1;
  for (widgetStartIndex; widgetStartIndex > 0; widgetStartIndex--) {
    const currentChar = lineText.charAt(widgetStartIndex);
    if (currentChar === " " || currentChar === openBracket) break;
  }
  widgetStartIndex++;

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
