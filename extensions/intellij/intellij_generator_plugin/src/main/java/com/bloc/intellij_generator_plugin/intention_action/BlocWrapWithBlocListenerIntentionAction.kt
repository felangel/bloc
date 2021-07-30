package com.bloc.intellij_generator_plugin.intention_action

class BlocWrapWithBlocListenerIntentionAction : BlocWrapWithIntentionAction(SnippetType.BlocListener) {
    /**
     * If this action is applicable, returns the text to be shown in the list of intention actions available.
     */
    override fun getText(): String {
        return "Wrap with BlocListener"
    }
}