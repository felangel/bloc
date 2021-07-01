package com.bloc.intellij_generator_plugin.action

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.psi.util.PsiUtilBase


class GenerateEquatablePropsAction : AnAction() {

//    override fun update(event: AnActionEvent?) {
//        super.update(event)
//        val action = event?.presentation;
//        if (action != null) {
//            val editor = event.getRequiredData(CommonDataKeys.EDITOR)
//            val project = event.project ?: return
//            val currentFile = PsiUtilBase.getPsiFileInEditor(editor, project)
//            action.isVisible = currentFile?.name?.endsWith(".dart") == true
//            action.isEnabledAndVisible
//        }
//    }

    override fun actionPerformed(event: AnActionEvent) {
        val editor = event.getRequiredData(CommonDataKeys.EDITOR)
        val project = event.project ?: return
        val currentFile = PsiUtilBase.getPsiFileInEditor(editor, project) ?: return

        val currentOffset = editor.caretModel.currentCaret.offset;
        val element = currentFile.findElementAt(currentOffset) ?: return
        var node = element.node;
        while (node != null) {
            if (node.toString() == "Element(CLASS_DEFINITION)") {
                break
            }
            node = node.treeParent
        }

        if (node == null) return
        val members = node.getChildren(null).find { astNode -> astNode.toString() == "Element(CLASS_BODY)" }
            ?.getChildren(null)?.find { astNode -> astNode.toString() == "Element(CLASS_MEMBERS)" }?.getChildren(null)
            ?.filter { astNode -> astNode.toString() == "Element(VAR_DECLARATION_LIST)" }

        if (members == null) return

        var isNullable = false
        val memberNames = members.map { n ->
            val memberNode = n.firstChildNode;
            if (memberNode.toString() == "Element(VAR_ACCESS_DECLARATION)") {
                val type =
                    memberNode.getChildren(null)
                        .find { astNode -> astNode.toString() == "Element(TYPE)" }?.psi

                if (!isNullable && type != null && editor.document.getText(type.textRange).endsWith("?")) {
                    isNullable = true
                }

                val member =
                    memberNode.getChildren(null).find { astNode -> astNode.toString() == "Element(COMPONENT_NAME)" }
                        ?.getChildren(null)
                        ?.find { astNode -> astNode.toString() == "Element(ID)" }?.getChildren(null)
                        ?.find { astNode -> astNode.toString() == "PsiElement(IDENTIFIER)" }?.psi

                return@map if (member == null) "" else editor.document.getText(member.textRange)
            }
            return@map ""
        }

        val nullStr = if (isNullable) "?" else ""
        var props: String = "";
        for ((i, s) in memberNames.withIndex()) {
            if (s != "") {
                if (i == 0 && memberNames.size == 1) {
                    props += s
                } else if (i == memberNames.size - 1) {
                    props += s
                } else {
                    props += "$s, "
                }
            }
        }
        val propsStr = "@override\nList<Object$nullStr> get props => [$props];"

        WriteCommandAction.runWriteCommandAction(project) {
            editor.document.insertString(currentOffset, propsStr)
        }
    }
}
