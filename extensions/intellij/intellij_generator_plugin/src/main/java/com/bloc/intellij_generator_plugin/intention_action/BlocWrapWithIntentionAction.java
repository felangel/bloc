package com.bloc.intellij_generator_plugin.intention_action;

import com.intellij.codeInsight.intention.IntentionAction;
import com.intellij.codeInsight.intention.PsiElementBaseIntentionAction;
import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.command.WriteCommandAction;
import com.intellij.openapi.editor.*;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.util.TextRange;
import com.intellij.psi.PsiDocumentManager;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiFile;
import com.intellij.psi.codeStyle.CodeStyleManager;
import com.intellij.util.IncorrectOperationException;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public abstract class BlocWrapWithIntentionAction extends PsiElementBaseIntentionAction implements IntentionAction {
    final SnippetType snippetType;
    PsiElement callExpressionElement;

    public BlocWrapWithIntentionAction(SnippetType snippetType) {
        this.snippetType = snippetType;
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
        return getText();
    }

    /**
     * Checks whether this intention is available at the caret offset in file - the caret must sit on a widget call.
     * If this condition is met, this intention's entry is shown in the available intentions list.
     *
     * <p>Note: this method must do its checks quickly and return.</p>
     *
     * @param project a reference to the Project object being edited.
     * @param editor  a reference to the object editing the project source
     * @param psiElement a reference to the PSI element currently under the caret
     * @return {@code true} if the caret is in a literal string element, so this functionality should be added to the
     * intention menu or {@code false} for all other types of caret positions
     */
    public boolean isAvailable(@NotNull Project project, Editor editor, @Nullable PsiElement psiElement) {
        if (psiElement == null) {
            return false;
        }

        final PsiFile currentFile = getCurrentFile(project, editor);
        if (currentFile != null && !currentFile.getName().endsWith(".dart")) {
            return false;
        }

        if (!psiElement.toString().equals("PsiElement(IDENTIFIER)")) {
            return false;
        }

        callExpressionElement = WrapHelper.callExpressionFinder(psiElement);
        if (callExpressionElement == null) {
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
        Runnable runnable = () -> invokeSnippetAction(project, editor, snippetType);
        WriteCommandAction.runWriteCommandAction(project, runnable);
    }

    protected void invokeSnippetAction(@NotNull Project project, Editor editor, SnippetType snippetType) {
        final Document document = editor.getDocument();

        final PsiElement element = callExpressionElement;
        final TextRange elementSelectionRange = element.getTextRange();
        final int offsetStart = elementSelectionRange.getStartOffset();
        final int offsetEnd = elementSelectionRange.getEndOffset();

        if (!WrapHelper.isSelectionValid(offsetStart, offsetEnd)) {
            return;
        }

        final String selectedText = document.getText(TextRange.create(offsetStart, offsetEnd));
        final String replaceWith = Snippets.getSnippet(snippetType, selectedText);

        // wrap the widget:
        WriteCommandAction.runWriteCommandAction(project, () -> {
                    document.replaceString(offsetStart, offsetEnd, replaceWith);
                }
        );

        // place cursors to specify types:
        final String prefixSelection = Snippets.PREFIX_SELECTION;
        final String[] snippetArr = {Snippets.BLOC_SNIPPET_KEY, Snippets.STATE_SNIPPET_KEY, Snippets.REPOSITORY_SNIPPET_KEY};

        final CaretModel caretModel = editor.getCaretModel();
        caretModel.removeSecondaryCarets();

        for (String snippet : snippetArr) {
            if (!replaceWith.contains(snippet)) {
                continue;
            }

            final int caretOffset = offsetStart + replaceWith.indexOf(snippet);
            final VisualPosition visualPos = editor.offsetToVisualPosition(caretOffset);
            caretModel.addCaret(visualPos);

            // select snippet prefix keys:
            final Caret currentCaret = caretModel.getCurrentCaret();
            currentCaret.setSelection(caretOffset, caretOffset + prefixSelection.length());
        }

        final Caret initialCaret = caretModel.getAllCarets().get(0);
        if (!initialCaret.hasSelection()) {
            // initial position from where was triggered the intention action
            caretModel.removeCaret(initialCaret);
        }

        // reformat file:
        ApplicationManager.getApplication().runWriteAction(() -> {
            PsiDocumentManager.getInstance(project).commitDocument(document);
            final PsiFile currentFile = getCurrentFile(project, editor);
            if (currentFile != null) {
                final String unformattedText = document.getText();
                final int unformattedLineCount = document.getLineCount();

                CodeStyleManager.getInstance(project).reformat(currentFile);

                final int formattedLineCount = document.getLineCount();

                // file was incorrectly formatted, revert formatting
                if (formattedLineCount > unformattedLineCount + 3) {
                    document.setText(unformattedText);
                    PsiDocumentManager.getInstance(project).commitDocument(document);
                }
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
