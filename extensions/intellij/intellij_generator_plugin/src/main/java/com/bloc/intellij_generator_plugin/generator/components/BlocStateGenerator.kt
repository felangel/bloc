package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.action.BlocStatePackage
import com.bloc.intellij_generator_plugin.generator.BlocGenerator

class BlocStateGenerator(
        name: String,
        blocStatePackage: BlocStatePackage
) : BlocGenerator(name, blocStatePackage, templateName = "bloc_state") {
    override fun fileName() = "${snakeCase()}_state.${fileExtension()}"
}
