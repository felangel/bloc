import { commands, SnippetString, window } from "vscode";
import { getSelectedText } from "../utils";

const interpolatedVarRegExp = /[$]/g;
const escapedCharacterRegExp = /[\\]/g;

export const wrapWith = async (snippet: (widget: string) => string) => {
  let editor = window.activeTextEditor;
  if (!editor) return;
  const selection = getSelectedText(editor);
  const widget = editor.document
    .getText(selection)
    .replace(escapedCharacterRegExp, "\\\\")
    .replace(interpolatedVarRegExp, "\\$");
  editor.insertSnippet(new SnippetString(snippet(widget)), selection);
  await commands.executeCommand("editor.action.formatDocument");
};
