package com.bloc.intellij_generator_plugin.intention_action

object Snippets {
    const val PREFIX_SELECTION = "Subject"

    private const val SUFFIX_BLOC = "Bloc"
    private const val SUFFIX_STATE = "State"
    private const val SUFFIX_REPOSITORY = "Repository"

    const val BLOC_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX_BLOC
    const val STATE_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX_STATE
    const val REPOSITORY_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX_REPOSITORY

    @JvmStatic
    fun getSnippet(snippetType: SnippetType?, widget: String): String {
        return when (snippetType) {
            SnippetType.BlocListener -> blocListenerSnippet(widget)
            SnippetType.BlocProvider -> blocProviderSnippet(widget)
            SnippetType.BlocConsumer -> blocConsumerSnippet(widget)
            SnippetType.RepositoryProvider -> repositoryProviderSnippet(widget)
            else -> blocBuilderSnippet(widget)
        }
    }

    private fun blocBuilderSnippet(widget: String): String {
        return "BlocBuilder<$BLOC_SNIPPET_KEY, $STATE_SNIPPET_KEY>(\n" +
                "  builder: (context, state) {\n" +
                "    return $widget;\n" +
                "  },\n" +
                ")"
    }

    private fun blocListenerSnippet(widget: String): String {
        return "BlocListener<$BLOC_SNIPPET_KEY, $STATE_SNIPPET_KEY>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener\n" +
                "  },\n" +
                "  child: $widget,\n" +
                ")"
    }

    private fun blocProviderSnippet(widget: String): String {
        return "BlocProvider(\n" +
                "  create: (context) => $BLOC_SNIPPET_KEY(),\n" +
                "  child: $widget,\n" +
                ")"
    }

    private fun blocConsumerSnippet(widget: String): String {
        return "BlocConsumer<$BLOC_SNIPPET_KEY, $STATE_SNIPPET_KEY>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener\n" +
                "  },\n" +
                "  builder: (context, state) {\n" +
                "    return $widget;\n" +
                "  },\n" +
                ")"
    }

    private fun repositoryProviderSnippet(widget: String): String {
        return "RepositoryProvider(\n" +
                "  create: (context) => $REPOSITORY_SNIPPET_KEY(),\n" +
                "    child: $widget,\n" +
                ")"
    }
}