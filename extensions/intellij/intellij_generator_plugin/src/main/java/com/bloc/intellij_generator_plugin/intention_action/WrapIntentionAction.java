package com.bloc.intellij_generator_plugin.intention_action;

import com.intellij.codeInsight.intention.IntentionAction;
import com.intellij.codeInsight.intention.PsiElementBaseIntentionAction;
import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.command.WriteCommandAction;
import com.intellij.openapi.editor.*;
import com.intellij.openapi.fileEditor.ex.FileEditorManagerEx;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.util.TextRange;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.psi.*;
import com.intellij.psi.codeStyle.CodeStyleManager;
import com.intellij.util.DocumentUtil;
import com.intellij.util.IncorrectOperationException;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;


public class WrapIntentionAction extends PsiElementBaseIntentionAction implements IntentionAction {

    /**
     * If this action is applicable, returns the text to be shown in the list of intention actions available.
     */
    @NotNull
    public String getText() {
        return "(Bloc) Wrap widget with ...";
    }

    /**
     * Returns text for name of this family of intentions.
     * It is used to externalize "auto-show" state of intentions.
     * It is also the directory name for the descriptions.
     *
     * @return the intention family name.
     */
    @NotNull
    public String getFamilyName() {
        return "Wrap widget";
    }

    /**
     * Checks whether this intention is available at the caret offset in file - the caret must sit just before a "?"
     * character in a ternary statement. If this condition is met, this intention's entry is shown in the available
     * intentions list.
     *
     * <p>Note: this method must do its checks quickly and return.</p>
     *
     * @param project a reference to the Project object being edited.
     * @param editor  a reference to the object editing the project source
     * @param element a reference to the PSI element currently under the caret
     * @return {@code true} if the caret is in a literal string element, so this functionality should be added to the
     * intention menu or {@code false} for all other types of caret positions
     */
    public boolean isAvailable(@NotNull Project project, Editor editor, @Nullable PsiElement element) {
        // Quick sanity check
        if (element == null) {
            return false;
        }

        // TODO: Add a condition whether should be menu 'Wrap with ...' displayed
        return true;
    }

    /**
     * Modifies the Psi to change a ternary expression to an if-then-else statement.
     * If the ternary is part of a declaration, the declaration is separated and moved above the if-then-else statement.
     * Called when user selects this intention action from the available intentions list.
     *
     * @param project a reference to the Project object being edited.
     * @param editor  a reference to the object editing the project source
     * @param element a reference to the PSI element currently under the caret
     * @throws IncorrectOperationException Thrown by underlying (Psi model) write action context
     *                                     when manipulation of the psi tree fails.
     *                                     //     * @see ConditionalOperatorConverter#startInWriteAction()
     */
    public void invoke(@NotNull Project project, Editor editor, @NotNull PsiElement element)
            throws IncorrectOperationException {

        final Document document = editor.getDocument();
        final Selection selection = Utils.getSelection(editor);

        final String selectedText = document.getText(TextRange.create(selection.offsetL, selection.offsetR));
        final String replaceWith = new Snippets().blocBuilderSnippet(selectedText);


        // wrap widget
        WriteCommandAction.runWriteCommandAction(project, () -> {
                    document.replaceString(selection.offsetL, selection.offsetR, replaceWith);
                }
        );

        // place cursors to specify types
        final String documentText = document.getText();

        final String snippetKey1 = "${0-BlocSnippetExt}";
        final String snippetKey2 = "${1-BlocSnippetExt}";

        final int startingCaretPos1 = documentText.indexOf(snippetKey1);
        final int lineStartOffset = DocumentUtil.getLineStartOffset(startingCaretPos1, document);
        final int lineNumber = document.getLineNumber(lineStartOffset);

        final int startingCaretPos2 = (documentText.substring(lineStartOffset)).indexOf(snippetKey2);

        // TODO: both carpets should be canceled with ESC (this key cancels one by one currently) or Enter key (this makes a new line currently)
        final CaretModel caretModel = editor.getCaretModel();
        caretModel.removeSecondaryCarets();
        caretModel.moveToOffset(startingCaretPos1);

        LogicalPosition logicalPositionCaret2 = new LogicalPosition(lineNumber, startingCaretPos2);
        // TODO: toVisualPosition is deprecated, replace with ???
        caretModel.addCaret(logicalPositionCaret2.toVisualPosition(), true);

        // TODO: refactor snippet key removal
        document.deleteString(startingCaretPos1, startingCaretPos1 + snippetKey1.length());
        document.deleteString(caretModel.getOffset(), caretModel.getOffset() + snippetKey2.length());

        // TODO: weird issue when testing with Flutter & dart plugin installed it splits some code (without them it's not doing that)
        // format file
//        ApplicationManager.getApplication().runWriteAction(() -> {
//            PsiDocumentManager.getInstance(project).commitDocument(document);
//            final FileEditorManagerEx fileEditorManagerEx = FileEditorManagerEx.getInstanceEx(project);
//            final VirtualFile currentFile = fileEditorManagerEx.getCurrentFile();
//            final PsiFile file;
//            if (currentFile != null) {
//                file = PsiManager.getInstance(project).findFile(currentFile);
//                if (file != null) {
//                    CodeStyleManager.getInstance(project).reformat(file);
//                }
//            }
////            CodeStyleManager.getInstance(project).reformat(element);
//        });
    }

    /**
     * Indicates this intention action expects the Psi framework to provide the write action context for any changes.
     *
     * @return {@code true} if the intention requires a write action context to be provided or {@code false} if this
     * intention action will start a write action
     */
    public boolean startInWriteAction() {
        return true;
    }
}

