package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.generator.components.BlocEventGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocGenerator
import com.bloc.intellij_generator_plugin.generator.components.BlocStateGenerator

object BlocGeneratorFactory {
    fun getBlocGenerators(name: String, useEquatable: Boolean): List<com.bloc.intellij_generator_plugin.generator.BlocGenerator> {
        val bloc = BlocGenerator(name, useEquatable)
        val event = BlocEventGenerator(name, useEquatable)
        val state = BlocStateGenerator(name, useEquatable)
        return listOf(bloc, event, state)
    }
}