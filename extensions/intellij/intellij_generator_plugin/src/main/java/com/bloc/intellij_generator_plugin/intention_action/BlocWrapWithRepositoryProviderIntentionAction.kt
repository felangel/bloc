package com.bloc.intellij_generator_plugin.intention_action;

import org.jetbrains.annotations.NotNull;

public class BlocWrapWithRepositoryProviderIntentionAction extends BlocWrapWithIntentionAction {
    public BlocWrapWithRepositoryProviderIntentionAction() { super(SnippetType.RepositoryProvider); }

    /**
     * If this action is applicable, returns the text to be shown in the list of intention actions available.
     */
    @NotNull
    public String getText() {
        return "Wrap with RepositoryProvider";
    }
}
