package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.action.BlocTemplateType
import com.bloc.intellij_generator_plugin.generator.BlocGenerator

class BlocEventGenerator(
        blocName: String,
        blocTemplateType: BlocTemplateType
) : BlocGenerator(blocName, blocTemplateType, templateName = "bloc_event") {

    override fun fileName() = "${snakeCase()}_event.${fileExtension()}"
}
