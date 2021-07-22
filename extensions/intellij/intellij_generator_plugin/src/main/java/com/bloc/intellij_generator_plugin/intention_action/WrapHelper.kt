package com.bloc.intellij_generator_plugin.intention_action

import com.intellij.lang.ASTNode
import com.intellij.psi.PsiElement

class WrapHelper {
    companion object {
        fun callExpressionFinder(psiElement: PsiElement): PsiElement? {
            var psiElementFinder: PsiElement? = psiElement.parent

            for (i in 1..10) {
                if (psiElementFinder == null) {
                    return null
                }

                if (psiElementFinder.toString() == "CALL_EXPRESSION") {
                    if (psiElementFinder.text.startsWith(psiElement.text)) {
                        return psiElementFinder
                    }
                    return null
                }
                psiElementFinder = psiElementFinder.parent
            }
            return null
        }

        fun blocWidgetChildFinder(element: PsiElement): PsiElement? {
            val node: ASTNode = element.node ?: return null
            val childArgument = findChildArgument(node) ?: return null
            return findChildWidget(childArgument)
        }

        private fun findChildArgument(node: ASTNode) = node.getChildren(null)
            .find { astNode -> astNode.toString() == "Element(ARGUMENTS)" }?.getChildren(null)
            ?.find { astNode -> astNode.toString() == "Element(ARGUMENT_LIST)" }?.getChildren(null)
            ?.firstOrNull { astNode -> astNode.toString() == "Element(NAMED_ARGUMENT)" && astNode.text.startsWith("child: ") }

        private fun findChildWidget(childArgument: ASTNode) = childArgument.getChildren(null)
            .firstOrNull { astNode -> astNode.toString() == "Element(CALL_EXPRESSION)" }?.psi

        fun isSelectionValid(start: Int, end: Int): Boolean {
            if (start <= -1 || end <= -1) {
                return false
            }

            if (start >= end) {
                return false
            }

            return true
        }
    }
}