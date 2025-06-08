package com.bloc.intellij_generator_plugin.language_server

import com.intellij.openapi.progress.ProgressIndicator
import com.intellij.openapi.progress.ProgressManager
import com.redhat.devtools.lsp4ij.installation.LanguageServerInstallerBase

class BlocLanguageServerInstaller : LanguageServerInstallerBase() {
    private val languageServer = BlocLanguageServer();

    override fun checkServerInstalled(indicator: ProgressIndicator): Boolean {
        progress("Checking if the language server is installed...", indicator)
        val installed = languageServer.areBlocToolsInstalled()
        ProgressManager.checkCanceled()
        return installed
    }

    @Throws(Exception::class)
    override fun install(indicator: ProgressIndicator) {
        progress("Downloading bloc tools...", indicator)
        val installed = languageServer.installBlocTools()
        ProgressManager.checkCanceled()
        if (!installed) throw Exception("Failed to install bloc tools")
    }
}