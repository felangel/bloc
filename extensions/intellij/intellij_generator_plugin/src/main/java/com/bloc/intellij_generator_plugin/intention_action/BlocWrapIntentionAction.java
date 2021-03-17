package com.bloc.intellij_generator_plugin.intention_action;

import com.intellij.codeInsight.intention.IntentionAction;
import com.intellij.codeInsight.intention.PsiElementBaseIntentionAction;
import com.intellij.openapi.actionSystem.*;
import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.command.WriteCommandAction;
import com.intellij.openapi.editor.*;
import com.intellij.openapi.fileEditor.ex.FileEditorManagerEx;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.util.TextRange;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.psi.*;
import com.intellij.psi.codeStyle.CodeStyleManager;
import com.intellij.util.IncorrectOperationException;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.List;

public class BlocWrapIntentionAction extends PsiElementBaseIntentionAction implements IntentionAction {

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
     * Checks whether this intention is available at the caret offset in file - the caret must sit on a widget call.
     * If this condition is met, this intention's entry is shown in the available intentions list.
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
        if (element == null) {
            return false;
        }

        final PsiFile psiFile = getCurrentFile(project, editor);
        if (psiFile != null && !psiFile.getName().endsWith(".dart")) {
            return false;
        }


        final SnippetSelection selection = Utils.getSelection(editor);
        if (selection.offsetL > selection.offsetR) {
            return false;
        }

        return true;
    }

    /**
     * Called when user selects this intention action from the available intentions list.
     *
     * @param project a reference to the Project object being edited.
     * @param editor  a reference to the object editing the project source
     * @param element a reference to the PSI element currently under the caret
     * @throws IncorrectOperationException Thrown by underlying (Psi model) write action context
     *                                     when manipulation of the psi tree fails.
     */
    public void invoke(@NotNull Project project, Editor editor, @NotNull PsiElement element)
            throws IncorrectOperationException {

        final DefaultActionGroup actionGroup = new DefaultActionGroup();
        for (SnippetType snippetType : SnippetType.values()) {
            actionGroup.add(new AnAction(snippetType.name()) {
                @Override
                public void actionPerformed(AnActionEvent e) {
                    Runnable runnable = () -> invokeSnippetAction(project, editor, snippetType);
                    WriteCommandAction.runWriteCommandAction(project, runnable);
                }
            });
        }
        final ActionPopupMenu popupMenu = ActionManager.getInstance().createActionPopupMenu(ActionPlaces.UNKNOWN, actionGroup);

        final LogicalPosition logicalPosition = editor.getCaretModel().getLogicalPosition();
        final int x = editor.logicalPositionToXY(logicalPosition).x + 50;
        final int y = editor.logicalPositionToXY(logicalPosition).y;
        popupMenu.getComponent().show(editor.getContentComponent(), x, y);
    }

    private void invokeSnippetAction(@NotNull Project project, Editor editor, SnippetType snippetType) {
        final Document document = editor.getDocument();

        final SnippetSelection selection = Utils.getSelection(editor);
        final String selectedText = document.getText(TextRange.create(selection.offsetL, selection.offsetR));
        final String replaceWith = Snippets.getSnippet(snippetType, selectedText);

        // wrap the widget:
        WriteCommandAction.runWriteCommandAction(project, () -> {
                    document.replaceString(selection.offsetL, selection.offsetR, replaceWith);
                }
        );

        // place cursors to specify types:
        final String snippetKey1 = Snippets.SNIPPET_KEY1;
        final String snippetKey2 = Snippets.SNIPPET_KEY2;

        final CaretModel caretModel = editor.getCaretModel();
        caretModel.removeSecondaryCarets();

        final int startingCaretPos1 = selection.offsetL + replaceWith.indexOf(snippetKey1);
        caretModel.moveToOffset(startingCaretPos1);

        if (replaceWith.contains(snippetKey2)) {
            final VisualPosition visualPosition1 = caretModel.getCurrentCaret().getVisualPosition();

            final int startingCaretPos2 = selection.offsetL + replaceWith.indexOf(snippetKey2);
            caretModel.moveToOffset(startingCaretPos2);

            caretModel.addCaret(visualPosition1);
        }

        // safely remove snippet keys:
        final List<Caret> allCarets = caretModel.getAllCarets();
        for (Caret caret : allCarets) {
            final int offset = caret.getOffset();
            caret.setSelection(offset, offset + snippetKey1.length());
            if (caret.getSelectedText() != null) {
                if (caret.getSelectedText().equals(snippetKey1) || caret.getSelectedText().equals(snippetKey2)) {
                    document.deleteString(caret.getSelectionStart(), caret.getSelectionEnd());
                }
            }
        }

        // format file:
        ApplicationManager.getApplication().runWriteAction(() -> {
            PsiDocumentManager.getInstance(project).commitDocument(document);
            final PsiFile currentFile = getCurrentFile(project, editor);
            if (currentFile != null) {
                CodeStyleManager.getInstance(project).reformat(currentFile);
            }
        });
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

    private PsiFile getCurrentFile(Project project, Editor editor) {
        return PsiDocumentManager.getInstance(project).getPsiFile(editor.getDocument());
    }
}
