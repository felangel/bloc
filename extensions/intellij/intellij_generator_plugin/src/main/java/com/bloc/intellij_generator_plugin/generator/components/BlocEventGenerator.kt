package com.bloc.intellij_generator_plugin.generator.components

import com.bloc.intellij_generator_plugin.action.BlocStatePackage
import com.bloc.intellij_generator_plugin.generator.BlocGenerator

class BlocEventGenerator(
        blocName: String,
        blocStatePackage: BlocStatePackage
) : BlocGenerator(blocName, blocStatePackage, templateName = "bloc_event") {

    override fun fileName() = "${snakeCase()}_event.${fileExtension()}"
}
