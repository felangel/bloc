package com.bloc.intellij_generator_plugin.intention_action;

public class Snippets {
    String blocBuilderSnippet(String widget) {
        return String.format("BlocBuilder<${0-BlocSnippetExt}Bloc, ${1-BlocSnippetExt}State>(\n" +
                "  builder: (context, state) {\n" +
                "    return %s;\n" +
                "  },\n" +
                ")", widget);
    }

    String blocListenerSnippet(String widget) {
        return String.format("BlocListener<${0-BlocSnippetExt}Bloc, ${1-BlocSnippetExt}State>(\n" +
                "  listener: (context, state) {\n" +
                "    \\${3:// TODO: implement listener}\n" +
                "  },\n" +
                "  child: %s,\n" +
                ")", widget);
    }

    String blocProviderSnippet(String widget) {
        return String.format("BlocProvider(\n" +
                "  create: (context) => \\${1:Subject}\\${2|Bloc,Cubit|}(),\n" +
                "  child: %s,\n" +
                ")", widget);
    }

    String blocConsumerSnippet(String widget) {
        return String.format("BlocConsumer<\\${1:Subject}\\${2|Bloc,Cubit|}, $1State>(\n" +
                "  listener: (context, state) {\n" +
                "    \\${3:// TODO: implement listener}\n" +
                "  },\n" +
                "  builder: (context, state) {\n" +
                "    return %s;\n" +
                "  },\n" +
                ")", widget);
    }

    String repositoryProviderSnippet(String widget) {
        return String.format("RepositoryProvider(\n" +
                "  create: (context) => \\${1:Subject}Repository(),\n" +
                "    child: %s,\n" +
                ")", widget);
    }
}
