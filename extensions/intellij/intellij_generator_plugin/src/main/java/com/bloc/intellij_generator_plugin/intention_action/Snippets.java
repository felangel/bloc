package com.bloc.intellij_generator_plugin.intention_action;

public class Snippets {
    public static final String PREFIX_SELECTION = "Subject";

    public static final String SUFFIX1 = "Bloc";
    public static final String SUFFIX2 = "State";
    public static final String SUFFIX3 = "Repository";

    public static final String BLOC_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX1;
    public static final String STATE_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX2;
    public static final String REPOSITORY_SNIPPET_KEY = PREFIX_SELECTION + SUFFIX3;

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
        return String.format("BlocBuilder<%1$s, %2$s>(\n" +
                "  builder: (context, state) {\n" +
                "    return %3$s;\n" +
                "  },\n" +
                ")", BLOC_SNIPPET_KEY, STATE_SNIPPET_KEY, widget);
    }

    private static String blocListenerSnippet(String widget) {
        return String.format("BlocListener<%1$s, %2$s>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener}\n" +
                "  },\n" +
                "  child: %3$s,\n" +
                ")", BLOC_SNIPPET_KEY, STATE_SNIPPET_KEY, widget);
    }

    private static String blocProviderSnippet(String widget) {
        return String.format("BlocProvider(\n" +
                "  create: (context) => %1$s(),\n" +
                "  child: %2$s,\n" +
                ")", BLOC_SNIPPET_KEY, widget);
    }

    private static String blocConsumerSnippet(String widget) {
        return String.format("BlocConsumer<%1$s, %2$s>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener\n" +
                "  },\n" +
                "  builder: (context, state) {\n" +
                "    return %3$s;\n" +
                "  },\n" +
                ")", BLOC_SNIPPET_KEY, STATE_SNIPPET_KEY, widget);
    }

    private static String repositoryProviderSnippet(String widget) {
        return String.format("RepositoryProvider(\n" +
                "  create: (context) => %1$s(),\n" +
                "    child: %2$s,\n" +
                ")", REPOSITORY_SNIPPET_KEY, widget);
    }
}
