package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.action.BlocTemplateType
import com.bloc.intellij_generator_plugin.generator.components.BlocEventGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocStateGenerator

object BlocGeneratorFactory {
    fun getBlocGenerators(name: String, blocTemplateType: BlocTemplateType): List<com.bloc.intellij_generator_plugin.generator.BlocGenerator> {
        val bloc = BlocGenerator(name, blocTemplateType)
        val event = BlocEventGenerator(name, blocTemplateType)
        val state = BlocStateGenerator(name, blocTemplateType)
        return listOf(bloc, event, state)
    }
}
