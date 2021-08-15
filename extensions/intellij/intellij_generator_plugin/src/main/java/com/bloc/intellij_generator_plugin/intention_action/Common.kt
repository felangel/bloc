package com.bloc.intellij_generator_plugin.intention_action

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.TextRange
import com.intellij.psi.PsiDocumentManager
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.codeStyle.CodeStyleManager

class Common {
    companion object {
        fun shouldDisplayWrapMenu(
            editor: Editor?,
            project: Project,
            psiElement: PsiElement
        ): Boolean {
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
            return true
        }

        fun getCurrentFile(project: Project, editor: Editor): PsiFile? =
            PsiDocumentManager.getInstance(project).getPsiFile(editor.document)

        fun invokeSnippetAction(
            project: Project,
            editor: Editor,
            snippetType: SnippetType?,
            callExpressionElement: PsiElement,
            blocChildWidget: PsiElement?
        ) {
            val document = editor.document
            val elementSelectionRange = callExpressionElement.textRange
            val offsetStart = elementSelectionRange.startOffset
            val offsetEnd = elementSelectionRange.endOffset
            if (!WrapHelper.isSelectionValid(offsetStart, offsetEnd)) {
                return
            }
            val selectedText = document.getText(TextRange.create(offsetStart, offsetEnd))

            val replaceWith: String
            if (blocChildWidget != null) {
                val blocChildWidgetText = blocChildWidget.text
                val movedBlocWithoutChild = selectedText.replaceFirst(blocChildWidgetText, "")
                    .replaceFirst("[^\\S\\r\\n]*child: ,\\s*".toRegex(), "")
                replaceWith = Snippets.getSnippet(snippetType, blocChildWidgetText, movedBlocWithoutChild)
            } else {
                replaceWith = Snippets.getSnippet(snippetType, "", selectedText)
            }

            // wrap the widget:
            WriteCommandAction.runWriteCommandAction(project) {
                document.replaceString(
                    offsetStart,
                    offsetEnd,
                    replaceWith
                )
            }

            // place cursors to specify types:
            val prefixSelection = Snippets.PREFIX_SELECTION
            val snippetArr =
                arrayOf(Snippets.BLOC_SNIPPET_KEY, Snippets.STATE_SNIPPET_KEY, Snippets.REPOSITORY_SNIPPET_KEY)
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
    }
}