package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.Generator

class BlocStateGenerator(
    blocName: String,
    blocShouldUseEquatable: Boolean
) : Generator(blocName, blocShouldUseEquatable, templateName = "bloc_state") {

    override fun fileName() = "${snakeCase()}_state.${fileExtension()}"
}