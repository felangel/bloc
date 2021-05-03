package com.bloc.intellij_generator_plugin.intention_action

import com.intellij.psi.PsiElement

class WrapHelper {
    companion object {
        @JvmStatic
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

        @JvmStatic
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