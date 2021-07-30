import { window, CodeAction, CodeActionProvider, CodeActionKind } from "vscode";
import { getSelectedText } from "../utils";

export class BlocCodeActionProvider implements CodeActionProvider {
  public provideCodeActions(): CodeAction[] {
    const editor = window.activeTextEditor;
    if (!editor) return [];

    const selectedText = editor.document.getText(getSelectedText(editor));
    if (selectedText === "") return [];
    return [
      {
        command: "extension.wrap-blocbuilder",
        title: "Wrap with BlocBuilder",
      },
      {
        command: "extension.wrap-blocselector",
        title: "Wrap with BlocSelector",
      },
      {
        command: "extension.wrap-bloclistener",
        title: "Wrap with BlocListener",
      },
      {
        command: "extension.wrap-blocconsumer",
        title: "Wrap with BlocConsumer",
      },
      {
        command: "extension.wrap-blocprovider",
        title: "Wrap with BlocProvider",
      },
      {
        command: "extension.wrap-repositoryprovider",
        title: "Wrap with RepositoryProvider",
      },
    ].map((c) => {
      let action = new CodeAction(c.title, CodeActionKind.Refactor);
      action.command = {
        command: c.command,
        title: c.title,
      };
      return action;
    });
  }
}
