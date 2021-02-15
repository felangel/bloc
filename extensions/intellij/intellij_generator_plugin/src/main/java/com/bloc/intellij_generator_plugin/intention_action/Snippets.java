package com.bloc.intellij_generator_plugin.intention_action;

enum SnippetType {
    BlocBuilder, BlocListener, BlocProvider, BlocConsumer, RepositoryProvider
}

public class Snippets {
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
        return String.format("BlocBuilder<${0-BlocSnippetKey}Bloc, ${1-BlocSnippetKey}State>(\n" +
                "  builder: (context, state) {\n" +
                "    return %s;\n" +
                "  },\n" +
                ")", widget);
    }

    private static String blocListenerSnippet(String widget) {
        return String.format("BlocListener<${0-BlocSnippetKey}Bloc, ${1-BlocSnippetKey}State>(\n" +
                "  listener: (context, state) {\n" +
                "    \\${3:// TODO: implement listener}\n" +
                "  },\n" +
                "  child: %s;\n" +
                ")", widget);
    }

    private static String blocProviderSnippet(String widget) {
        return String.format("BlocProvider(\n" +
                "  create: (context) => ${0-BlocSnippetKey}Bloc(),\n" +
                "  child: %s;\n" +
                ")", widget);
    }

    private static String blocConsumerSnippet(String widget) {
        return String.format("BlocConsumer<${0-BlocSnippetKey}Bloc, ${1-BlocSnippetKey}State>(\n" +
                "  listener: (context, state) {\n" +
                "    // TODO: implement listener\n" +
                "  },\n" +
                "  builder: (context, state) {\n" +
                "    return %s;\n" +
                "  },\n" +
                ")", widget);
    }

    private static String repositoryProviderSnippet(String widget) {
        return String.format("RepositoryProvider(\n" +
                "  create: (context) => ${0-BlocSnippetKey}Repository(),\n" +
                "    child: %s;\n" +
                ")", widget);
    }
}
