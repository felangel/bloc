package com.bloc.intellij_generator_plugin.intention_action

import com.bloc.intellij_generator_plugin.intention_action.Common.Companion.invokeSnippetAction
import com.bloc.intellij_generator_plugin.intention_action.WrapHelper.Companion.blocWidgetChildFinder
import com.bloc.intellij_generator_plugin.intention_action.WrapHelper.Companion.callExpressionFinder
import com.intellij.codeInsight.intention.IntentionAction
import com.intellij.codeInsight.intention.PsiElementBaseIntentionAction
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.project.Project
import com.intellij.psi.PsiElement
import com.intellij.util.IncorrectOperationException

abstract class BlocConvertToMultiIntentionAction(private val snippetType: SnippetType) :
    PsiElementBaseIntentionAction(),
    IntentionAction {
    var callExpressionElement: PsiElement? = null
    var blocChildCallExpressionElement: PsiElement? = null

    override fun getFamilyName(): String = text

    override fun isAvailable(project: Project, editor: Editor?, psiElement: PsiElement): Boolean {
        val shouldDisplayWrapMenu = Common.shouldDisplayWrapMenu(editor, project, psiElement)
        if (!shouldDisplayWrapMenu) return false

        callExpressionElement = callExpressionFinder(psiElement)
        if (callExpressionElement == null) return false

        return shouldDisplayConvertMenu()
    }

    private fun shouldDisplayConvertMenu(): Boolean {
        val widgetName = callExpressionElement?.text ?: return false
        if (widgetName.startsWith(snippetType.toString().removePrefix("Multi"))
        ) {
            val blocChildWidget = blocWidgetChildFinder(callExpressionElement!!) ?: return false
            blocChildCallExpressionElement = blocChildWidget
            return true
        }
        return false
    }

    @Throws(IncorrectOperationException::class)
    override fun invoke(project: Project, editor: Editor, element: PsiElement) {
        val runnable = Runnable {
            invokeSnippetAction(
                project,
                editor,
                snippetType,
                callExpressionElement!!,
                blocChildCallExpressionElement!!
            )
        }
        WriteCommandAction.runWriteCommandAction(project, runnable)
    }

    override fun startInWriteAction(): Boolean = true
}