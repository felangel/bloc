package com.bloc.intellij_generator_plugin.intention_action;

public class Snippets {
    // snippet keys are used for locating snippets in the document and placing cursor(s)
    public static final String SNIPPET_KEY1 = "${0-BlocSnippetKey}";
    public static final String SNIPPET_KEY2 = "${1-BlocSnippetKey}";

    static String getSnippet(SnippetType snippetType, String widget) {
        switch (snippetType) {
            case BlocListener:
                return blocListenerSnippet(widget);
            case BlocProvider:
                return blocProviderSnippet(widget);
            case BlocConsumer:
                return blocConsumerSnippet(widget);
            case RepositoryProvider:
                return repositoryProviderSnippet(widget);
            default:
                return blocBuilderSnippet(widget);
        }
    }

    private static String blocBuilderSnippet(String widget) {
        return String.format("BlocBuilder<%1$sBloc, %2$sState>(\n" +
                "  builder: (context, state) {\n" +
                "    return %3$s;\n" +
                "  },\n" +
                ")", SNIPPET_KEY1, SNIPPET_KEY2, widget);
    }

    private static String blocListenerSnippet(String widget) {
        return String.format("BlocListener<%1$sBloc, %2$sState>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener}\n" +
                "  },\n" +
                "  child: %3$s,\n" +
                ")", SNIPPET_KEY1, SNIPPET_KEY2, widget);
    }

    private static String blocProviderSnippet(String widget) {
        return String.format("BlocProvider(\n" +
                "  create: (context) => %1$sBloc(),\n" +
                "  child: %2$s,\n" +
                ")", SNIPPET_KEY1, widget);
    }

    private static String blocConsumerSnippet(String widget) {
        return String.format("BlocConsumer<%1$sBloc, %2$sState>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener\n" +
                "  },\n" +
                "  builder: (context, state) {\n" +
                "    return %3$s;\n" +
                "  },\n" +
                ")", SNIPPET_KEY1, SNIPPET_KEY2, widget);
    }

    private static String repositoryProviderSnippet(String widget) {
        return String.format("RepositoryProvider(\n" +
                "  create: (context) => %1$sRepository(),\n" +
                "    child: %2$s,\n" +
                ")", SNIPPET_KEY1, widget);
    }
}
