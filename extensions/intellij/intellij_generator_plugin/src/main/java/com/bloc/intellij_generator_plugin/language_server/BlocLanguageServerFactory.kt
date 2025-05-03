package com.bloc.intellij_generator_plugin.language_server

import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.notification.NotificationGroupManager
import com.intellij.notification.NotificationType
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.LanguageServerFactory
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider
import java.util.concurrent.TimeUnit

class BlocLanguageServerFactory : LanguageServerFactory {
    private val logger = Logger.getInstance(BlocLanguageServerFactory::class.java)

    override fun createConnectionProvider(project: Project): StreamConnectionProvider {
        if (!isBlocToolsInstalled()) {
            if (!installBlocTools(project)) {
                throw IllegalStateException("bloc_tools installation failed")
            }
        }
        return BlocLanguageServer()
    }

    private fun isBlocToolsInstalled(): Boolean {
        try {
            val commandLine = GeneralCommandLine("bloc", "--version")
            val process = commandLine.createProcess()
            val hasExited = process.waitFor(5, TimeUnit.SECONDS)

            return hasExited && process.exitValue() == 0
        } catch (e: Exception) {
            logger.info("bloc_tools not found: ${e.message}")
            return false
        }
    }

    private fun installBlocTools(project: Project): Boolean {
        try {
            logger.info("installing bloc_tools")
            val commandLine = GeneralCommandLine("dart", "pub", "global", "activate", "bloc_tools")
            val process = commandLine.createProcess()
            val exitCode = process.waitFor()

            if (exitCode != 0) {
                logger.error("bloc_tools installation failed with exit code: $exitCode")
                showNotification(project, "bloc_tools installation failed", NotificationType.ERROR)
                return false
            }
            return true
        } catch (e: Exception) {
            logger.error("bloc_tools installation failed: ${e.message}")
            showNotification(project, "bloc_tools installation failed: ${e.message}", NotificationType.ERROR)
            return false
        }
    }

    private fun showNotification(project: Project, content: String, type: NotificationType) {
        NotificationGroupManager.getInstance()
            .getNotificationGroup("Bloc Plugin Notifications")
            .createNotification(content, type)
            .notify(project)
    }
}