package com.bloc.intellij_generator_plugin.generator

import com.google.common.base.CaseFormat
import com.google.common.io.CharStreams
import org.apache.commons.lang.text.StrSubstitutor
import java.io.InputStreamReader
import java.lang.RuntimeException

abstract class Generator(private val blocName: String,
                         blocShouldUseEquatable: Boolean,
                         templateName: String) {

    private val TEMPLATE_BLOC_CAMEL_CASE = "bloc_camel_case"
    private val TEMPLATE_BLOC_SNAKE_CASE = "bloc_snake_case"

    private val templateString: String
    private val templateValues: MutableMap<String, String>

    init {
        templateValues = mutableMapOf(
            TEMPLATE_BLOC_CAMEL_CASE to camelCase(),
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

    fun camelCase(): String = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, blocName)

    fun snakeCase() = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.LOWER_UNDERSCORE, blocName)

    fun fileExtension() = "dart"
}