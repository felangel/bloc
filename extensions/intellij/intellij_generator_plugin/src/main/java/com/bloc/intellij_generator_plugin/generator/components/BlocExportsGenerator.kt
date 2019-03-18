package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.generator.Generator

class BlocExportsGenerator(
    blocName: String,
    blocShouldUseEquatable: Boolean
) : Generator(blocName, blocShouldUseEquatable, templateName = "bloc_exports") {

    override fun fileName() = "bloc.${fileExtension()}"
}