package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.action.BlocTemplateType
import com.bloc.intellij_generator_plugin.generator.CubitGenerator

class CubitGenerator(
        name: String,
        blocTemplateType: BlocTemplateType
) : CubitGenerator(name, blocTemplateType, templateName = "cubit") {
    override fun fileName() = "${snakeCase()}_cubit.${fileExtension()}"
}
