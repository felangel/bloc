package com.bloc.intellij_generator_plugin.action

import com.bloc.intellij_generator_plugin.generator.BlocGeneratorFactory
import com.bloc.intellij_generator_plugin.generator.Generator
import com.intellij.lang.java.JavaLanguage
import com.intellij.openapi.actionSystem.*
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.command.CommandProcessor
import com.intellij.openapi.module.Module
import com.intellij.openapi.module.ModuleUtilCore
import com.intellij.openapi.project.Project
import com.intellij.openapi.roots.JavaProjectRootsUtil
import com.intellij.openapi.roots.ModuleRootManager
import com.intellij.openapi.roots.ProjectRootManager
import com.intellij.openapi.roots.SourceFolder
import com.intellij.psi.*
import com.intellij.refactoring.PackageWrapper
import com.intellij.refactoring.util.RefactoringUtil
import org.jetbrains.jps.model.java.JavaModuleSourceRootTypes
import org.jetbrains.jps.model.java.JavaSourceRootType

class GenerateBlocAction : AnAction(), GenerateBlocDialog.Listener {

    private lateinit var dataContext: DataContext

    override fun actionPerformed(e: AnActionEvent) {
        val dialog = GenerateBlocDialog(this)
        dialog.show()
    }

    override fun onGenerateBlocClicked(blocName: String?, shouldUseEquatable: Boolean) {
        blocName?.let { name ->
            val generators = BlocGeneratorFactory.getBlocGenerators(name, shouldUseEquatable)
            generate(generators)
        }
    }

    override fun update(e: AnActionEvent) {
        e.dataContext.let {
            this.dataContext = it
            val presentation = e.presentation
            val available = isAvailable(dataContext)
            presentation.isEnabled = available
        }
    }

    protected fun generate(mainSourceGenerators: List<Generator>) {
        val project = CommonDataKeys.PROJECT.getData(dataContext)
        val view = LangDataKeys.IDE_VIEW.getData(dataContext)
        val directory = view?.orChooseDirectory
        ApplicationManager.getApplication().runWriteAction {
            CommandProcessor.getInstance().executeCommand(
                project,
                {
                    mainSourceGenerators.forEach { createSourceFile(project!!, it, directory!!) }
                },
                "Generate a new Bloc",
                null
            )
        }
    }

    private fun isAvailable(dataContext: DataContext): Boolean {
        val project = CommonDataKeys.PROJECT.getData(dataContext)
        val view = LangDataKeys.IDE_VIEW.getData(dataContext)
        return if (project == null || view == null || view.directories.isEmpty()) {
            false
        } else {
            val projectFileIndex = ProjectRootManager.getInstance(project).fileIndex
            view.directories.forEach { directory ->
                if (projectFileIndex.isUnderSourceRootOfType(directory.virtualFile, JavaModuleSourceRootTypes.SOURCES) && packageExists(directory)) {
                    return true
                }
            }
            false
        }
    }

    private fun packageExists(directory: PsiDirectory): Boolean {
        val pkg = JavaDirectoryService.getInstance().getPackage(directory)
        return if (pkg == null) {
            false
        } else {
            val name = pkg.qualifiedName
            name.isEmpty() || PsiNameHelper.getInstance(directory.project).isQualifiedName(name)
        }
    }

    private fun createSourceFile(project: Project, generator: Generator, directory: PsiDirectory) {
        val fileName = generator.fileName()
        val psiFile = PsiFileFactory.getInstance(project)
            .createFileFromText(fileName, JavaLanguage.INSTANCE, generator.generate())
        directory.add(psiFile)
    }
}