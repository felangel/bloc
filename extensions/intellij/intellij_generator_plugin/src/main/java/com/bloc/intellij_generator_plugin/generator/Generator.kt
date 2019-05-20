package com.bloc.intellij_generator_plugin.generator

import com.google.common.io.CharStreams
import com.fleshgrinder.extensions.kotlin.*
import org.apache.commons.lang.text.StrSubstitutor
import java.io.InputStreamReader
import java.lang.RuntimeException

abstract class Generator(private val blocName: String,
                         blocShouldUseEquatable: Boolean,
                         templateName: String) {

    private val TEMPLATE_BLOC_PASCAL_CASE = "bloc_pascal_case"
    private val TEMPLATE_BLOC_SNAKE_CASE = "bloc_snake_case"

    private val templateString: String
    private val templateValues: MutableMap<String, String>

    init {
        templateValues = mutableMapOf(
            TEMPLATE_BLOC_PASCAL_CASE to pascalCase(),
            TEMPLATE_BLOC_SNAKE_CASE to snakeCase()
        )
        try {
            val templateFolder = if (blocShouldUseEquatable) "with_equatable" else "without_equatable"
            val resource = "/templates/$templateFolder/$templateName.dart.template"
            val resourceAsStream = Generator::class.java.getResourceAsStream(resource)
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

    fun pascalCase(): String = blocName.toUpperCamelCase()

    fun snakeCase() = blocName.toLowerSnakeCase()

    fun fileExtension() = "dart"
}