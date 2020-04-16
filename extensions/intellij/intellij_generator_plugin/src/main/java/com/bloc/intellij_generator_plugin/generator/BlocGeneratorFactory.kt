package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.generator.components.BlocEventGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocStateGenerator

object BlocGeneratorFactory {

    fun getBlocGenerators(blocName: String, blocShouldUseEquatable: Boolean): List<Generator> {
        val bloc = BlocGenerator(blocName, blocShouldUseEquatable)
        val event = BlocEventGenerator(blocName, blocShouldUseEquatable)
        val state = BlocStateGenerator(blocName, blocShouldUseEquatable)
        return listOf(bloc, event, state)
    }
}