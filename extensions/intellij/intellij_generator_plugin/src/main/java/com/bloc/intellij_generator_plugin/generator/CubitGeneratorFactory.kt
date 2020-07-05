package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.generator.components.CubitGenerator
import com.bloc.intellij_generator_plugin.generator.components.CubitStateGenerator

object CubitGeneratorFactory {
    fun getCubitGenerators(name: String, useEquatable: Boolean): List<com.bloc.intellij_generator_plugin.generator.CubitGenerator> {
        val cubit = CubitGenerator(name, useEquatable)
        val state = CubitStateGenerator(name, useEquatable)
        return listOf(cubit, state)
    }
}