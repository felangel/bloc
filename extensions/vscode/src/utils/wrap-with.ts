import { window, commands, SnippetString } from "vscode";
import { getSelectedText } from "../utils";

export const wrapWith = async (snippet: (widget: string) => string) => {
  let editor = window.activeTextEditor;
  if (!editor) return;
  const selection = getSelectedText(editor);
  const widget = editor.document.getText(selection);
  // insertSnippet will execute the $ expression in the widget text, 
  // so first escape the $ to prevent it from being executed incorrectly, 
  // and insertSnippet will also eliminate the escape.
  const escapedWidget = widget.replace(/\$/g, '\\$');
  editor.insertSnippet(new SnippetString(snippet(escapedWidget)), selection);
  await commands.executeCommand("editor.action.formatDocument");
};
