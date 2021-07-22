package com.bloc.intellij_generator_plugin.live_templates

import com.intellij.codeInsight.template.TemplateContextType
import com.intellij.psi.PsiFile

class BlocContext : TemplateContextType("Bloc", "Bloc") {
    override fun isInContext(file: PsiFile, offset: Int): Boolean {
        return file.name.endsWith(".dart")
    }
}