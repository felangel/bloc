import { window, Command, CodeActionProvider } from "vscode";
import { getSelectedText } from "../utils";

export class BlocCodeActionProvider implements CodeActionProvider {
  public provideCodeActions(): Command[] {
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
    ];
  }
}
