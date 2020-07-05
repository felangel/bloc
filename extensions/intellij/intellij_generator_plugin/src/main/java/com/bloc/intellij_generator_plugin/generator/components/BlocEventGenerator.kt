package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.BlocGenerator

class BlocEventGenerator(
    blocName: String,
    blocShouldUseEquatable: Boolean
) : BlocGenerator(blocName, blocShouldUseEquatable, templateName = "bloc_event") {

    override fun fileName() = "${snakeCase()}_event.${fileExtension()}"
}