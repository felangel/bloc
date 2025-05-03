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
    private val targetBlocToolsVersion = "0.1.0-dev.11"

    override fun createConnectionProvider(project: Project): StreamConnectionProvider {
        val blocToolsVersion = getBlocToolsVersion()
        val isUpgrade = blocToolsVersion != null
        if (blocToolsVersion != targetBlocToolsVersion) {
            if (!installOrUpgradeBlocTools(project, isUpgrade)) {
                throw IllegalStateException("bloc_tools ${if (isUpgrade) "upgrade" else "installation"} failed")
            }
        }
        return BlocLanguageServer()
    }

    private fun getBlocToolsVersion(): String? {
        try {
            val commandLine = GeneralCommandLine("bloc", "--version")
            val process = commandLine.createProcess()
            val hasExited = process.waitFor(5, TimeUnit.SECONDS)
            if (!hasExited || process.exitValue() != 0) return null
            return process.inputStream.bufferedReader().readLine().orEmpty().trim()
        } catch (e: Exception) {
            logger.debug("bloc --version failed: ${e.message}")
            return null
        }
    }

    private fun installOrUpgradeBlocTools(project: Project, isUpgrade: Boolean): Boolean {
        val verb = if (isUpgrade) "upgrade" else "install"
        val errorMessage = "Unable to $verb bloc_tools";
        try {
            val commandLine = GeneralCommandLine("dart", "pub", "global", "activate", "bloc_tools", targetBlocToolsVersion)
            val process = commandLine.createProcess()
            val exitCode = process.waitFor()
            if (exitCode != 0) {
                logger.error("bloc_tools activation exited with code: $exitCode")
                showNotification(project, errorMessage, NotificationType.ERROR)
                return false
            }
            return true
        } catch (e: Exception) {
            logger.error("bloc_tools activation failed: ${e.message}")
            showNotification(project, "$errorMessage: ${e.message}", NotificationType.ERROR)
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