package com.bloc.intellij_generator_plugin.action

import com.intellij.lang.ASTNode
import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.ActionUpdateThread
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Document
import com.intellij.psi.PsiDocumentManager
import com.intellij.psi.PsiElement
import com.intellij.psi.codeStyle.CodeStyleManager
import com.intellij.psi.util.PsiUtilBase


class GenerateEquatablePropsAction : AnAction() {
    override fun getActionUpdateThread(): ActionUpdateThread = ActionUpdateThread.BGT

    private var propsNullable = false

    override fun update(event: AnActionEvent) {
        super.update(event)
        val action = event.presentation;
        val editor = event.getRequiredData(CommonDataKeys.EDITOR)
        val project = event.project ?: return
        val currentFile = PsiUtilBase.getPsiFileInEditor(editor, project)
        action.isEnabledAndVisible = currentFile?.name?.endsWith(".dart") == true
    }

    override fun actionPerformed(event: AnActionEvent) {
        val project = event.project ?: return
        val editor = event.getRequiredData(CommonDataKeys.EDITOR)

        val currentFile = PsiUtilBase.getPsiFileInEditor(editor, project) ?: return
        val currentOffset = editor.caretModel.currentCaret.offset
        val element = currentFile.findElementAt(currentOffset) ?: return

        val classNode = findClassDefinition(element) ?: return
        val members = findAllClassMembers(classNode) ?: return
        val memberNames = getPropsList(editor.document, members)

        val nullStr = if (propsNullable) "?" else ""
        propsNullable = false

        val props: String = reformatProps(memberNames.filter { s -> s != "" })
        val propsStr = "@override\nList<Object$nullStr> get props => [$props];"

        WriteCommandAction.runWriteCommandAction(project) {
            editor.document.insertString(currentOffset, propsStr)
            PsiDocumentManager.getInstance(project).commitDocument(editor.document)
            CodeStyleManager.getInstance(project).reformat(currentFile)
        }
    }

    private fun findClassDefinition(element: PsiElement): ASTNode? {
        var node: ASTNode? = element.node
        while (node != null) {
            if (node.toString() == "Element(CLASS_DEFINITION)") {
                break
            }
            node = node.treeParent
        }
        return node
    }

    private fun findAllClassMembers(node: ASTNode) =
        node.getChildren(null).find { astNode -> astNode.toString() == "Element(CLASS_BODY)" }
            ?.getChildren(null)?.find { astNode -> astNode.toString() == "Element(CLASS_MEMBERS)" }?.getChildren(null)
            ?.filter { astNode -> astNode.toString() == "Element(VAR_DECLARATION_LIST)" }

    private fun findNonAccessModifiers(memberNode: ASTNode) = memberNode.getChildren(null)
        .filter { astNode -> astNode.toString().startsWith("PsiElement(") }

    private fun findMemberType(memberNode: ASTNode) = memberNode.getChildren(null)
        .find { astNode -> astNode.toString() == "Element(TYPE)" }

    private fun findMemberName(memberNode: ASTNode) =
        memberNode.getChildren(null).find { astNode -> astNode.toString() == "Element(COMPONENT_NAME)" }
            ?.getChildren(null)
            ?.find { astNode -> astNode.toString() == "Element(ID)" }?.getChildren(null)
            ?.find { astNode -> astNode.toString() == "PsiElement(IDENTIFIER)" }

    private fun getPropsList(
        doc: Document,
        members: List<ASTNode>
    ) = members.map { n ->
        val memberNode = n.firstChildNode
        if (memberNode.toString() == "Element(VAR_ACCESS_DECLARATION)") {
            val accessModifiers = findNonAccessModifiers(memberNode)

            // list only class members with non-access modifier "final", but not with "static final" or without any
            if (accessModifiers.size == 1 && accessModifiers[0].toString() == "PsiElement(final)") {
                val type = findMemberType(memberNode)?.psi
                if (!propsNullable && type != null && doc.getText(type.textRange).endsWith("?")) {
                    propsNullable = true
                }

                val member = findMemberName(memberNode)?.psi

                return@map if (member == null) "" else doc.getText(member.textRange)
            }
        }
        return@map ""
    }

    private fun reformatProps(memberNames: List<String>): String {
        var props = ""
        for ((i, s) in memberNames.withIndex()) {
            if (memberNames.size == 1 || (i == memberNames.size - 1)) {
                props += s
            } else {
                props += "$s, "
            }
        }

        if (props.length >= 45) {
            // line probably longer than 80 chars
            props += ","
        }

        return props
    }
}
