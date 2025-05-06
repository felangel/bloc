package com.bloc.intellij_generator_plugin.language_server

import com.bloc.intellij_generator_plugin.util.BlocPluginNotification
import com.bloc.intellij_generator_plugin.util.CommandLineHelper
import com.bloc.intellij_generator_plugin.util.VersionComparator
import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.notification.NotificationType
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.server.OSProcessStreamConnectionProvider
import java.util.concurrent.atomic.AtomicBoolean

class BlocLanguageServer(private val project: Project? = null) :
    OSProcessStreamConnectionProvider(GeneralCommandLine("bloc", "language-server")) {

    companion object {
        private const val PROCESS_TIMEOUT_SECONDS: Long = 5
        private const val TARGET_BLOC_TOOLS_VERSION = "0.1.0-dev.11"
        private const val MIN_DART_VERSION = "3.7.0"
    }

    private val logger = Logger.getInstance(BlocLanguageServer::class.java)
    private val minVersionAlertShowed = AtomicBoolean(false)
    private val dartVersionRegex = Regex("Dart SDK version: ((?:[0-9]*\\.?)*)")

    override fun start() {
        if (project != null && checkRequirements(project)) {
            logger.error("Bloc language server could not be started because requirements are not met.")
            return
        }

        super.start()
    }

    fun checkRequirements(project: Project): Boolean {
        if (!hasRequiredDartVersion()) {
            if (minVersionAlertShowed.compareAndSet(false, true)) {
                BlocPluginNotification.notify(
                    project,
                    "The bloc language server requires a newer version of the Dart SDK (>=$MIN_DART_VERSION).",
                    NotificationType.ERROR
                )
                logger.error("Installation doesn't match Dart version requirement")
            }
            return false
        }
        val blocToolsVersion = getBlocToolsVersion()
        val isUpgrade = blocToolsVersion != null
        if (blocToolsVersion != TARGET_BLOC_TOOLS_VERSION) {
            if (!installOrUpgradeBlocTools(project, isUpgrade)) {
                logger.error("bloc_tools ${if (isUpgrade) "upgrade" else "installation"} failed")
                return false
            }
        }
        return true
    }

    private fun hasRequiredDartVersion(): Boolean {
        val dartVersion = getDartVersion()
        if (dartVersion == null) {
            return false
        }
        return VersionComparator.isGreaterOrEqualThan(dartVersion, MIN_DART_VERSION)
    }

    private fun getDartVersion(): String? {
        val value = CommandLineHelper.executeWithTimeout(PROCESS_TIMEOUT_SECONDS, "dart", "--version")
        if (value.isNullOrBlank()) {
            return null
        }
        return dartVersionRegex.find(value)?.groupValues?.get(1)
    }

    private fun getBlocToolsVersion(): String? =
        CommandLineHelper.executeWithTimeout(PROCESS_TIMEOUT_SECONDS, "bloc", "--version")

    private fun installOrUpgradeBlocTools(project: Project, isUpgrade: Boolean): Boolean {
        val verb = if (isUpgrade) "upgrade" else "install"
        val errorMessage = "Unable to $verb bloc_tools"
        try {
            val commandLine =
                GeneralCommandLine("dart", "pub", "global", "activate", "bloc_tools", TARGET_BLOC_TOOLS_VERSION)
            val process = commandLine.createProcess()
            val exitCode = process.waitFor()
            if (exitCode != 0) {
                logger.error("bloc_tools activation exited with code: $exitCode")
                BlocPluginNotification.notify(project, errorMessage, NotificationType.ERROR)
                return false
            }
            return true
        } catch (e: Exception) {
            logger.error("bloc_tools activation failed: ${e.message}")
            BlocPluginNotification.notify(project, "$errorMessage: ${e.message}", NotificationType.ERROR)
            return false
        }
    }
}
