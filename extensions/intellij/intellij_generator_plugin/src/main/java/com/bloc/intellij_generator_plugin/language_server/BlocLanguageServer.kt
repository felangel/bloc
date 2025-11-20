package com.bloc.intellij_generator_plugin.language_server

import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.openapi.diagnostic.Logger
import com.redhat.devtools.lsp4ij.server.OSProcessStreamConnectionProvider
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider
import com.intellij.openapi.application.PathManager
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import java.net.URI

private const val BLOC_TOOLS_VERSION = "0.1.0-dev.20"

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

class BlocLanguageServer() {
    private val logger = Logger.getInstance(BlocLanguageServer::class.java)
    private var provider: OSProcessStreamConnectionProvider? = null

    fun areBlocToolsInstalled(): Boolean {
        val executable = getBlocToolsExecutableFile()
        return executable?.exists() == true
    }

    fun installBlocTools(): Boolean {
        val executableFile = getBlocToolsExecutableFile() ?: return false
        try {
            val uri =
                URI("https://github.com/felangel/bloc/releases/download/bloc_tools-v$BLOC_TOOLS_VERSION/${executableFile.name}")
            val cacheDir = getCacheDirectory()
            cacheDir.mkdirs()
            downloadFile(uri.toURL(), executableFile)
            makeExecutable(executableFile)
        } catch (e: Exception) {
            logger.error("Failed to download bloc tools", e)
        }
        return executableFile.exists()
    }

    fun getConnectionProvider(): StreamConnectionProvider? {
        val executable = getBlocToolsExecutableFile() ?: return null
        if (!executable.exists()) return null

        val commandLine = GeneralCommandLine(executable.absolutePath, "language-server")
        provider = OSProcessStreamConnectionProvider(commandLine)
        return provider
    }

    private fun getBlocToolsExecutableFile(): File? {
        val os = OperatingSystem.fromSystemProperty()
        val arch = Architecture.fromSystemProperty()

        if (os == OperatingSystem.Unknown || arch == Architecture.Unknown) {
            logger.warn("Unsupported OS or architecture")
            return null
        }

        val fileName = "bloc_${os.value}_${arch.value}"
        val cacheDir = getCacheDirectory()
        return File(cacheDir, fileName)
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
