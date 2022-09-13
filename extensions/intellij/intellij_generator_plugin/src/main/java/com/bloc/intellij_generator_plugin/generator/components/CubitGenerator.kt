package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.action.BlocStatePackage
import com.bloc.intellij_generator_plugin.generator.CubitGenerator

class CubitGenerator(
        name: String,
        blocStatePackage: BlocStatePackage
) : CubitGenerator(name, blocStatePackage, templateName = "cubit") {
    override fun fileName() = "${snakeCase()}_cubit.${fileExtension()}"
}
