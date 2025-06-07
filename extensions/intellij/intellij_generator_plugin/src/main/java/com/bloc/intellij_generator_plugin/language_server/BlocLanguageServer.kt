package com.bloc.intellij_generator_plugin.language_server

import com.bloc.intellij_generator_plugin.util.BlocPluginNotification
import com.bloc.intellij_generator_plugin.util.MultiplatformCommandLine
import com.intellij.notification.NotificationType
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.intellij.openapi.progress.ProgressManager
import com.redhat.devtools.lsp4ij.server.OSProcessStreamConnectionProvider
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider
import com.intellij.openapi.application.PathManager
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import java.net.URI

private const val BLOC_TOOLS_VERSION = "0.1.0-dev.15"

enum class OperatingSystem(val value: String) {
    Linux("linux"),
    MacOS("macos"),
    Windows("windows"),
    Unknown("-");

    companion object {
        fun fromSystemProperty(): OperatingSystem {
            val os = System.getProperty("os.name").lowercase()
            return when {
                os.contains("win") -> Windows
                os.contains("mac") -> MacOS
                os.contains("nix") || os.contains("nux") || os.contains("aix") -> Linux
                else -> Unknown
            }
        }
    }
}

enum class Architecture(val value: String) {
    X64("x64"),
    Arm64("arm64"),
    Unknown("-");

    companion object {
        fun fromSystemProperty(): Architecture {
            val arch = System.getProperty("os.arch").lowercase()
            return when (arch) {
                in listOf("amd64", "x86_64") -> X64
                in listOf("aarch64", "arm64") -> Arm64
                else -> Unknown
            }
        }
    }
}

class BlocLanguageServer(private val project: Project? = null) {
    private val logger = Logger.getInstance(BlocLanguageServer::class.java)
    private var provider: OSProcessStreamConnectionProvider? = null

    fun getConnectionProvider(): StreamConnectionProvider? {
        if (project == null) {
            logger.error("Bloc language server could not be started because no project was detected.")
            return null
        }

        val executable = getBlocToolsExecutable(project)
        if (executable == null) return null

        val commandLine = MultiplatformCommandLine(executable, "language-server")
        provider = OSProcessStreamConnectionProvider(commandLine)
        return provider
    }

    private fun getBlocToolsExecutable(project: Project): String? {
        val os = OperatingSystem.fromSystemProperty()
        val arch = Architecture.fromSystemProperty()

        if (os == OperatingSystem.Unknown || arch == Architecture.Unknown) {
            logger.warn("Unsupported OS or architecture")
            return null
        }

        val fileName = "bloc_${os.value}_${arch.value}" + if (os == OperatingSystem.Windows) ".exe" else ""
        val cacheDir = getCacheDirectory();
        val executableFile = File(cacheDir, fileName)

        if (executableFile.exists()) {
            logger.info("Found cached executable at ${executableFile.absolutePath}")
            return executableFile.absolutePath
        }

        val success = ProgressManager.getInstance().runProcessWithProgressSynchronously(
            {
                try {
                    val uri =
                        URI("https://github.com/felangel/bloc/releases/download/bloc_tools-v$BLOC_TOOLS_VERSION/$fileName")
                    cacheDir.mkdirs()
                    downloadFile(uri.toURL(), executableFile)
                    makeExecutable(executableFile)
                } catch (e: Exception) {
                    logger.error("Failed to download bloc tools", e)
                }

            }, "Installing the Bloc Language Server",
            false,
            project
        )

        if (success && executableFile.exists()) {
            BlocPluginNotification.notify(project, "Bloc Language Server installed", NotificationType.INFORMATION)
            return executableFile.absolutePath
        }

        BlocPluginNotification.notify(
            project,
            "Failed to install the Bloc Language Server. See logs for details.",
            NotificationType.ERROR
        )

        return null;
    }

    private fun makeExecutable(file: File) {
        if (!file.setExecutable(true, false)) {
            logger.error("Failed to set executable: ${file.absolutePath}")
        }
    }

    private fun downloadFile(url: URL, outputFile: File) {
        url.openStream().use { input ->
            FileOutputStream(outputFile).use { output ->
                input.copyTo(output)
            }
        }
    }

    private fun getCacheDirectory(): File {
        val pluginCacheDir = File(PathManager.getSystemPath(), "bloc-tools/$BLOC_TOOLS_VERSION")
        pluginCacheDir.mkdirs()
        return pluginCacheDir
    }
}
