package com.bloc.intellij_generator_plugin.language_server

import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.LanguageServerFactory
import com.redhat.devtools.lsp4ij.client.features.LSPClientFeatures
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider
import java.io.InputStream
import java.io.OutputStream

@Suppress("UnstableApiUsage")
class BlocLanguageServerFactory : LanguageServerFactory {
    private val logger = Logger.getInstance(BlocLanguageServer::class.java)

    override fun createClientFeatures(): LSPClientFeatures {
        val features = LSPClientFeatures()
        features.setServerInstaller(BlocLanguageServerInstaller())
        return features
    }

    override fun createConnectionProvider(project: Project): StreamConnectionProvider {
        val languageServer = BlocLanguageServer()
        return languageServer.getConnectionProvider() ?: run {
            logger.warn("Bloc Language Server could not be initialized — falling back to no-op connection provider")
            NoopConnectionProvider()
        }
    }
}

class NoopConnectionProvider : StreamConnectionProvider {
    override fun start() {
        // no-op
    }

    override fun stop() {
        // no-op
    }

    override fun getInputStream(): InputStream? = null

    override fun getOutputStream(): OutputStream? = null
}