package com.bloc.intellij_generator_plugin.generator

import com.bloc.intellij_generator_plugin.action.BlocTemplateType
import com.fleshgrinder.extensions.kotlin.toLowerSnakeCase
import com.fleshgrinder.extensions.kotlin.toUpperCamelCase
import com.google.common.io.CharStreams
import org.apache.commons.lang.text.StrSubstitutor
import java.io.InputStreamReader

abstract class BlocGenerator(private val name: String,
                             blocTemplateType: BlocTemplateType,
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
            val templateFolder = when (blocTemplateType) {
                BlocTemplateType.BASIC -> "bloc_basic"
                BlocTemplateType.EQUATABLE -> "bloc_equatable"
                BlocTemplateType.FREEZED -> "bloc_freezed"
            }
            val resource = "/templates/$templateFolder/$templateName.dart.template"
            val resourceAsStream = BlocGenerator::class.java.getResourceAsStream(resource)
            templateString = CharStreams.toString(InputStreamReader(resourceAsStream, Charsets.UTF_8))
        } catch (e: Exception) {
            throw RuntimeException(e)
        }
    }

    abstract fun fileName(): String

    fun generate(): String {
        val substitutor = StrSubstitutor(templateValues, "{{", "}}", '\\')
        return substitutor.replace(templateString)
    }

    fun pascalCase(): String = name.toUpperCamelCase().replace("Bloc", "")

    fun snakeCase() = name.toLowerSnakeCase().replace("_bloc", "")

    fun fileExtension() = "dart"
}
