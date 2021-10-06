package com.bloc.intellij_generator_plugin.intention_action

class BlocConvertToMultiBlocListenerIntentionAction : BlocConvertToMultiIntentionAction(SnippetType.MultiBlocListener) {
    /**
     * If this action is applicable, returns the text to be shown in the list of intention actions available.
     */
    override fun getText(): String {
        return "Convert to MultiBlocListener"
    }
}