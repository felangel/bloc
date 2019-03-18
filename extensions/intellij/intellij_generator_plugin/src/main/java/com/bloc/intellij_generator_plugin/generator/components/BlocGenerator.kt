package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.Generator

class BlocGenerator(
    blocName: String,
    blocShouldUseEquatable: Boolean
) : Generator(blocName, blocShouldUseEquatable, templateName = "bloc") {

    override fun fileName() = "${snakeCase()}_bloc.${fileExtension()}"
}