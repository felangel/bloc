package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.action.BlocTemplateType
import com.bloc.intellij_generator_plugin.generator.BlocGenerator

class BlocGenerator(
        name: String,
        blocTemplateType: BlocTemplateType
) : BlocGenerator(name, blocTemplateType, templateName = "bloc") {
    override fun fileName() = "${snakeCase()}_bloc.${fileExtension()}"
}
