package com.bloc.intellij_generator_plugin.intention_action

import com.bloc.intellij_generator_plugin.intention_action.Common.Companion.invokeSnippetAction
import com.bloc.intellij_generator_plugin.intention_action.WrapHelper.Companion.callExpressionFinder
import com.intellij.codeInsight.intention.IntentionAction
import com.intellij.codeInsight.intention.PsiElementBaseIntentionAction
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.project.Project
import com.intellij.psi.PsiElement
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
        val shouldDisplay = Common.shouldDisplayWrapMenu(editor, project, psiElement)
        if (shouldDisplay) {
            callExpressionElement = callExpressionFinder(psiElement)
            return callExpressionElement != null
        }
        return false
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
        val runnable = Runnable { invokeSnippetAction(project, editor, snippetType, callExpressionElement!!, null) }
        WriteCommandAction.runWriteCommandAction(project, runnable)
    }

    /**
     * Indicates this intention action expects the Psi framework to provide the write action context for any changes.
     *
     * @return `true` if the intention requires a write action context to be provided or `false` if this
     * intention action will start a write action
     */
    override fun startInWriteAction(): Boolean = true
}