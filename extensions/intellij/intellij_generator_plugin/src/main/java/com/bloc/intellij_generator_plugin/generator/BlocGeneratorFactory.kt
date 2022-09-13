package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.action.BlocStatePackage
import com.bloc.intellij_generator_plugin.generator.components.BlocEventGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocStateGenerator

object BlocGeneratorFactory {
    fun getBlocGenerators(name: String, blocStatePackage: BlocStatePackage): List<com.bloc.intellij_generator_plugin.generator.BlocGenerator> {
        val bloc = BlocGenerator(name, blocStatePackage)
        val event = BlocEventGenerator(name, blocStatePackage)
        val state = BlocStateGenerator(name, blocStatePackage)
        return listOf(bloc, event, state)
    }
}
