package com.bloc.intellij_generator_plugin.intention_action

object Snippets {
    const val PREFIX_SELECTION = "Subject"

    private const val SUFFIX_BLOC = "Bloc"
    private const val SUFFIX_CUBIT = "Cubit"
    private const val SUFFIX_STATE = "State"
    private const val SUFFIX_REPOSITORY = "Repository"

    const val SELECTED_STATE_SNIPPET_KEY = "SelectedState"
    const val BLOC_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX_BLOC
    const val STATE_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX_STATE
    const val REPOSITORY_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX_REPOSITORY

    @JvmStatic
    fun getSnippet(snippetType: SnippetType?, blocWidget: String, widget: String): String {
        return when (snippetType) {
            SnippetType.BlocSelector -> blocSelectorSnippet(widget)
            SnippetType.CubitSelector -> blocSelectorSnippet(widget, SUFFIX_CUBIT)
            SnippetType.BlocListener -> blocListenerSnippet(widget)
            SnippetType.CubitListener -> blocListenerSnippet(widget, SUFFIX_CUBIT)
            SnippetType.BlocProvider -> blocProviderSnippet(widget)
            SnippetType.CubitProvider -> blocProviderSnippet(widget, SUFFIX_CUBIT)
            SnippetType.BlocConsumer -> blocConsumerSnippet(widget)
            SnippetType.CubitConsumer -> blocConsumerSnippet(widget, SUFFIX_CUBIT)
            SnippetType.RepositoryProvider -> repositoryProviderSnippet(widget)
            SnippetType.MultiBlocProvider -> multiBlocProviderSnippet(blocWidget, widget)
            SnippetType.MultiBlocListener -> multiBlocListenerSnippet(blocWidget, widget)
            SnippetType.MultiRepositoryProvider -> multiRepositoryProviderSnippet(blocWidget, widget)
            else -> blocBuilderSnippet(widget)
        }
    }

    private fun blocBuilderSnippet(widget: String, type: String = SUFFIX_BLOC): String {
        return "BlocBuilder<$PREFIX_SELECTION$type, $STATE_SNIPPET_KEY>(\n" +
                "  builder: (context, state) {\n" +
                "    return $widget;\n" +
                "  },\n" +
                ")"
    }

    private fun blocSelectorSnippet(widget: String, type: String = SUFFIX_BLOC): String {
        return "BlocSelector<$PREFIX_SELECTION$type, $STATE_SNIPPET_KEY, $SELECTED_STATE_SNIPPET_KEY>(\n" +
                "  selector: (state) {\n" +
                "    // TODO: return selected state\n" +
                "  },\n" +
                "  builder: (context, state) {\n" +
                "    return $widget;\n" +
                "  },\n" +
                ")"
    }

    private fun blocListenerSnippet(widget: String, type: String = SUFFIX_BLOC): String {
        return "BlocListener<$PREFIX_SELECTION$type, $STATE_SNIPPET_KEY>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener\n" +
                "  },\n" +
                "  child: $widget,\n" +
                ")"
    }

    private fun blocProviderSnippet(widget: String, type: String = SUFFIX_BLOC): String {
        return "BlocProvider(\n" +
                "  create: (context) => $PREFIX_SELECTION$type(),\n" +
                "  child: $widget,\n" +
                ")"
    }

    private fun blocConsumerSnippet(widget: String, type: String = SUFFIX_BLOC): String {
        return "BlocConsumer<$PREFIX_SELECTION$type, $STATE_SNIPPET_KEY>(\n" +
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

    private fun multiBlocProviderSnippet(blocChildWidget: String, widget: String): String {
        return "MultiBlocProvider(\n" +
                "  providers: [\n" +
                "    $widget,\n" +
                "    BlocProvider(\n" +
                "      create: (context) => $BLOC_SNIPPET_KEY(),\n" +
                "    ),\n" +
                "  ],\n" +
                "  child: $blocChildWidget,\n" +
                ")"
    }

    private fun multiBlocListenerSnippet(blocChildWidget: String, widget: String): String {
        return "MultiBlocListener(\n" +
                "  listeners: [\n" +
                "    $widget,\n" +
                "    BlocListener<$BLOC_SNIPPET_KEY, $STATE_SNIPPET_KEY>(\n" +
                "      listener: (context, state) {\n" +
                "        // TODO: implement listener\n" +
                "      },\n" +
                "    ),\n" +
                "  ],\n" +
                "  child: $blocChildWidget,\n" +
                ")"
    }

    private fun multiRepositoryProviderSnippet(blocChildWidget: String, widget: String): String {
        return "MultiRepositoryProvider(\n" +
                "  providers: [\n" +
                "    $widget,\n" +
                "    RepositoryProvider(\n" +
                "      create: (context) => $REPOSITORY_SNIPPET_KEY(),\n" +
                "    ),\n" +
                "  ],\n" +
                "  child: $blocChildWidget,\n" +
                ")"
    }
}