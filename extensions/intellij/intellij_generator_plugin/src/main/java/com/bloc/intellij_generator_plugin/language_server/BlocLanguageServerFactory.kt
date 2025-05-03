package com.bloc.intellij_generator_plugin.language_server

import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.LanguageServerFactory
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider

class BlocLanguageServerFactory : LanguageServerFactory {
    // TODO: Check if bloc_tools is installed before
    override fun createConnectionProvider(project: Project): StreamConnectionProvider = BlocLanguageServer()
}