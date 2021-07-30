package com.bloc.intellij_generator_plugin.intention_action

import com.bloc.intellij_generator_plugin.intention_action.Snippets.getSnippet
import com.bloc.intellij_generator_plugin.intention_action.WrapHelper.Companion.callExpressionFinder
import com.bloc.intellij_generator_plugin.intention_action.WrapHelper.Companion.isSelectionValid
import com.intellij.codeInsight.intention.IntentionAction
import com.intellij.codeInsight.intention.PsiElementBaseIntentionAction
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.TextRange
import com.intellij.psi.PsiDocumentManager
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.codeStyle.CodeStyleManager
import com.intellij.util.IncorrectOperationException

abstract class BlocWrapWithIntentionAction(private val snippetType: SnippetType) : PsiElementBaseIntentionAction(),
    IntentionAction {
    var callExpressionElement: PsiElement? = null

    /**
     * Returns text for name of this family of intentions.
     * It is used to externalize "auto-show" state of intentions.
     * It is also the directory name for the descriptions.
     *
     * @return the intention family name.
     */
    override fun getFamilyName(): String = text

    /**
     * Checks whether this intention is available at the caret offset in file - the caret must sit on a widget call.
     * If this condition is met, this intention's entry is shown in the available intentions list.
     *
     *
     * Note: this method must do its checks quickly and return.
     *
     * @param project a reference to the Project object being edited.
     * @param editor  a reference to the object editing the project source
     * @param psiElement a reference to the PSI element currently under the caret
     * @return `true` if the caret is in a literal string element, so this functionality should be added to the
     * intention menu or `false` for all other types of caret positions
     */
    override fun isAvailable(project: Project, editor: Editor?, psiElement: PsiElement): Boolean {
        if (editor == null) {
            return false
        }
        val currentFile = getCurrentFile(project, editor)
        if (currentFile != null && !currentFile.name.endsWith(".dart")) {
            return false
        }
        if (psiElement.toString() != "PsiElement(IDENTIFIER)") {
            return false
        }
        callExpressionElement = callExpressionFinder(psiElement)
        return callExpressionElement != null
    }

    /**
     * Called when user selects this intention action from the available intentions list.
     *
     * @param project a reference to the Project object being edited.
     * @param editor  a reference to the object editing the project source
     * @param element a reference to the PSI element currently under the caret
     * @throws IncorrectOperationException Thrown by underlying (Psi model) write action context
     * when manipulation of the psi tree fails.
     */
    @Throws(IncorrectOperationException::class)
    override fun invoke(project: Project, editor: Editor, element: PsiElement) {
        val runnable = Runnable { invokeSnippetAction(project, editor, snippetType) }
        WriteCommandAction.runWriteCommandAction(project, runnable)
    }

    protected fun invokeSnippetAction(project: Project, editor: Editor, snippetType: SnippetType?) {
        val document = editor.document
        val element = callExpressionElement
        val elementSelectionRange = element!!.textRange
        val offsetStart = elementSelectionRange.startOffset
        val offsetEnd = elementSelectionRange.endOffset
        if (!isSelectionValid(offsetStart, offsetEnd)) {
            return
        }
        val selectedText = document.getText(TextRange.create(offsetStart, offsetEnd))
        val replaceWith = getSnippet(snippetType, selectedText)

        // wrap the widget:
        WriteCommandAction.runWriteCommandAction(project) { document.replaceString(offsetStart, offsetEnd, replaceWith) }

        // place cursors to specify types:
        val prefixSelection = Snippets.PREFIX_SELECTION
        val snippetArr = arrayOf(Snippets.BLOC_SNIPPET_KEY, Snippets.STATE_SNIPPET_KEY, Snippets.REPOSITORY_SNIPPET_KEY)
        val caretModel = editor.caretModel
        caretModel.removeSecondaryCarets()
        for (snippet in snippetArr) {
            if (!replaceWith.contains(snippet)) {
                continue
            }
            val caretOffset = offsetStart + replaceWith.indexOf(snippet)
            val visualPos = editor.offsetToVisualPosition(caretOffset)
            caretModel.addCaret(visualPos)

            // select snippet prefix keys:
            val currentCaret = caretModel.currentCaret
            currentCaret.setSelection(caretOffset, caretOffset + prefixSelection.length)
        }
        val initialCaret = caretModel.allCarets[0]
        if (!initialCaret.hasSelection()) {
            // initial position from where was triggered the intention action
            caretModel.removeCaret(initialCaret)
        }

        // reformat file:
        ApplicationManager.getApplication().runWriteAction {
            PsiDocumentManager.getInstance(project).commitDocument(document)
            val currentFile = getCurrentFile(project, editor)
            if (currentFile != null) {
                val unformattedText = document.text
                val unformattedLineCount = document.lineCount
                CodeStyleManager.getInstance(project).reformat(currentFile)
                val formattedLineCount = document.lineCount

                // file was incorrectly formatted, revert formatting
                if (formattedLineCount > unformattedLineCount + 3) {
                    document.setText(unformattedText)
                    PsiDocumentManager.getInstance(project).commitDocument(document)
                }
            }
        }
    }

    /**
     * Indicates this intention action expects the Psi framework to provide the write action context for any changes.
     *
     * @return `true` if the intention requires a write action context to be provided or `false` if this
     * intention action will start a write action
     */
    override fun startInWriteAction(): Boolean = true

    private fun getCurrentFile(project: Project, editor: Editor): PsiFile? =
        PsiDocumentManager.getInstance(project).getPsiFile(editor.document)
}