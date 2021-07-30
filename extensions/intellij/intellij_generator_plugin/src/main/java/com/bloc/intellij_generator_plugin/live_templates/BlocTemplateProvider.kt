package com.bloc.intellij_generator_plugin.live_templates

import com.intellij.codeInsight.template.impl.DefaultLiveTemplatesProvider

class BlocTemplateProvider : DefaultLiveTemplatesProvider {
    override fun getDefaultLiveTemplateFiles(): Array<String> {
        return arrayOf("liveTemplates/Bloc")
    }

    override fun getHiddenLiveTemplateFiles(): Array<String>? {
        return null
    }
}