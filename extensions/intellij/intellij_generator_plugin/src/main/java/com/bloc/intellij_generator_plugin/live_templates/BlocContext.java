package com.bloc.intellij_generator_plugin.live_templates;

import com.intellij.codeInsight.template.TemplateContextType;
import com.intellij.psi.PsiFile;
import org.jetbrains.annotations.NotNull;

public class BlocContext extends TemplateContextType {
    protected BlocContext() {
        super("Bloc", "Bloc");
    }

    @Override
    public boolean isInContext(@NotNull PsiFile file, int offset) {
        return file.getName().endsWith(".dart");
    }
}
