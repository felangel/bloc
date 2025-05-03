package com.bloc.intellij_generator_plugin.language_server

import com.intellij.execution.configurations.GeneralCommandLine
import com.redhat.devtools.lsp4ij.server.OSProcessStreamConnectionProvider

class BlocLanguageServer : OSProcessStreamConnectionProvider(GeneralCommandLine("bloc", "language-server"))