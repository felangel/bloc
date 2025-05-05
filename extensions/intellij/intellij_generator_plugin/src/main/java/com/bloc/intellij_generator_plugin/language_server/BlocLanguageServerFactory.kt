package com.bloc.intellij_generator_plugin.language_server

import com.bloc.intellij_generator_plugin.util.VersionComparator
import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.notification.NotificationGroupManager
import com.intellij.notification.NotificationType
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.LanguageServerEnablementSupport
import com.redhat.devtools.lsp4ij.LanguageServerFactory
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

class BlocLanguageServerFactory : LanguageServerFactory, LanguageServerEnablementSupport {
    private val logger = Logger.getInstance(BlocLanguageServerFactory::class.java)
    private val minVersionAlertShowed = AtomicBoolean(false)
    private val targetBlocToolsVersion = "0.1.0-dev.11"
    private val minDartVersion = "3.7.0"
    private val dartVersionRegex = Regex("Dart SDK version: ((?:[0-9]*\\.?)*)")

    override fun createConnectionProvider(project: Project): StreamConnectionProvider = BlocLanguageServer()

    private fun hasRequiredDartVersion(): Boolean {
        val dartVersion = getDartVersion()
        if (dartVersion == null) {
            return false
        }
        return VersionComparator.isGreaterOrEqualThan(dartVersion, minDartVersion)
    }

    private fun getDartVersion(): String? {
        try {
            val commandLine = GeneralCommandLine("dart", "--version")
            val process = commandLine.createProcess()
            val hasExited = process.waitFor(5, TimeUnit.SECONDS)
            if (!hasExited || process.exitValue() != 0) return null
            val value = process.inputStream.bufferedReader().readText()
            return dartVersionRegex.find(value)?.groupValues?.get(1)
        } catch (e: Exception) {
            logger.debug("dart --version failed: ${e.message}")
            return null
        }
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
        val errorMessage = "Unable to $verb bloc_tools"
        try {
            val commandLine =
                GeneralCommandLine("dart", "pub", "global", "activate", "bloc_tools", targetBlocToolsVersion)
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

    override fun isEnabled(project: Project): Boolean {
        val blocToolsVersion = getBlocToolsVersion()
        val isUpgrade = blocToolsVersion != null
        if (!hasRequiredDartVersion()) {
            if (minVersionAlertShowed.compareAndSet(false, true)) {
                showNotification(
                    project,
                    "The bloc language server requires a newer version of the Dart SDK (>=$minDartVersion).",
                    NotificationType.ERROR
                )
                logger.error("Installation doesn't match Dart version requirement")
            }
            return false
        }
        if (blocToolsVersion != targetBlocToolsVersion) {
            if (!installOrUpgradeBlocTools(project, isUpgrade)) {
                logger.error("bloc_tools ${if (isUpgrade) "upgrade" else "installation"} failed")
                return false
            }
        }
        return true
    }

    override fun setEnabled(enabled: Boolean, project: Project) {
        // TODO: Implement this with settings
    }
}