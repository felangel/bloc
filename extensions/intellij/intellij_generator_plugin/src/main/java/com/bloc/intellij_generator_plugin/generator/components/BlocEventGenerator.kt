package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.Generator

class BlocEventGenerator(
    blocName: String,
    blocShouldUseEquatable: Boolean
) : Generator(blocName, blocShouldUseEquatable, templateName = "bloc_event") {

    override fun fileName() = "${snakeCase()}_event.${fileExtension()}"
}