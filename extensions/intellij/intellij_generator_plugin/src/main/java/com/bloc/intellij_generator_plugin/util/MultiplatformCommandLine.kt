package com.bloc.intellij_generator_plugin.util

import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.openapi.util.SystemInfo

class MultiplatformCommandLine(exePath: String, vararg parameters: String): GeneralCommandLine() {
    init {
        val adjustedExePath =
            if (SystemInfo.isWindows && !exePath.endsWith(".bat", ignoreCase = true)) "$exePath.bat" else exePath
        setExePath(adjustedExePath)
        addParameters(*parameters)
    }
}