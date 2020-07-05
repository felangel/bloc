package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.CubitGenerator

class CubitStateGenerator(
    name: String,
    useEquatable: Boolean
) : CubitGenerator(name, useEquatable, templateName = "cubit_state") {
    override fun fileName() = "${snakeCase()}_state.${fileExtension()}"
}