package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.BlocGenerator

class BlocGenerator(
    name: String,
    useEquatable: Boolean
) : BlocGenerator(name, useEquatable, templateName = "bloc") {
    override fun fileName() = "${snakeCase()}_bloc.${fileExtension()}"
}