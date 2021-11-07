import { window, commands, SnippetString } from "vscode";
import { getSelectedText } from "../utils";

const childRegExp = new RegExp("[^S\r\n]*child: .*,s*", "ms");

export const convertTo = async (
  snippet: (widget: string, child: string) => string
) => {
  let editor = window.activeTextEditor;
  if (!editor) return;
  const selection = getSelectedText(editor);
  const rawWidget = editor.document.getText(selection).replace("$", "//$");
  const match = rawWidget.match(childRegExp);
  if (!match || !match.length) return;
  const child = match[0];
  if (!child) return;
  const widget = rawWidget.replace(childRegExp, "");
  editor.insertSnippet(new SnippetString(snippet(widget, child)), selection);
  await commands.executeCommand("editor.action.formatDocument");
};
