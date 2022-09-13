package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.action.BlocStatePackage
import com.bloc.intellij_generator_plugin.generator.components.CubitGenerator
import com.bloc.intellij_generator_plugin.generator.components.CubitStateGenerator

object CubitGeneratorFactory {
    fun getCubitGenerators(name: String, blocStatePackage: BlocStatePackage): List<com.bloc.intellij_generator_plugin.generator.CubitGenerator> {
        val cubit = CubitGenerator(name, blocStatePackage)
        val state = CubitStateGenerator(name, blocStatePackage)
        return listOf(cubit, state)
    }
}
