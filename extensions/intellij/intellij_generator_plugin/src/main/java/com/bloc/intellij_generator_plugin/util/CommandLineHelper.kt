package com.bloc.intellij_generator_plugin.util

import com.intellij.openapi.diagnostic.Logger
import java.util.concurrent.TimeUnit

object CommandLineHelper {
    private val logger = Logger.getInstance(CommandLineHelper::class.java)

    fun executeWithTimeout(timeout: Long, exePath: String, vararg parameters: String): String? {
        try {
            val commandLine = MultiplatformCommandLine(exePath, *parameters)
            val process = commandLine.createProcess()
            val hasExited = process.waitFor(timeout, TimeUnit.SECONDS)
            if (!hasExited || process.exitValue() != 0) return null
            return process.inputStream.bufferedReader().readLine().orEmpty().trim()
        } catch (e: Exception) {
            logger.debug("fail to execute command ($exePath ${parameters.joinToString(" ")}): ${e.message}")
            return null
        }
    }
}