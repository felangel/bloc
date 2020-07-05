package com.bloc.intellij_generator_plugin.generator

import com.google.common.io.CharStreams
import com.fleshgrinder.extensions.kotlin.*
import org.apache.commons.lang.text.StrSubstitutor
import java.io.InputStreamReader
import java.lang.RuntimeException

abstract class CubitGenerator(private val name: String,
                             useEquatable: Boolean,
                             templateName: String) {

    private val TEMPLATE_CUBIT_PASCAL_CASE = "cubit_pascal_case"
    private val TEMPLATE_CUBIT_SNAKE_CASE = "cubit_snake_case"

    private val templateString: String
    private val templateValues: MutableMap<String, String>

    init {
        templateValues = mutableMapOf(
            TEMPLATE_CUBIT_PASCAL_CASE to pascalCase(),
            TEMPLATE_CUBIT_SNAKE_CASE to snakeCase()
        )
        try {
            val templateFolder = if (useEquatable) "cubit_with_equatable" else "cubit_without_equatable"
            val resource = "/templates/$templateFolder/$templateName.dart.template"
            val resourceAsStream = CubitGenerator::class.java.getResourceAsStream(resource)
            templateString = CharStreams.toString(InputStreamReader(resourceAsStream, Charsets.UTF_8))
        } catch (e: Exception) {
            throw RuntimeException(e)
        }
    }

    abstract fun fileName(): String

    fun generate(): String {
        val substitutor = StrSubstitutor(templateValues)
        return substitutor.replace(templateString)
    }

    fun pascalCase(): String = name.toUpperCamelCase().replace("Cubit", "")

    fun snakeCase() = name.toLowerSnakeCase().replace("_cubit", "")

    fun fileExtension() = "dart"
}