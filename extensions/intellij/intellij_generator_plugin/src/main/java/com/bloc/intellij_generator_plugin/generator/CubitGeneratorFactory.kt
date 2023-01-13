package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.action.BlocTemplateType
import com.bloc.intellij_generator_plugin.generator.components.CubitGenerator
import com.bloc.intellij_generator_plugin.generator.components.CubitStateGenerator

object CubitGeneratorFactory {
    fun getCubitGenerators(name: String, blocTemplateType: BlocTemplateType): List<com.bloc.intellij_generator_plugin.generator.CubitGenerator> {
        val cubit = CubitGenerator(name, blocTemplateType)
        val state = CubitStateGenerator(name, blocTemplateType)
        return listOf(cubit, state)
    }
}
