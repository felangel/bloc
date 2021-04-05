package com.bloc.intellij_generator_plugin.intention_action;


import com.intellij.openapi.editor.Document;
import com.intellij.openapi.editor.Editor;
import com.intellij.openapi.editor.SelectionModel;
import com.intellij.util.DocumentUtil;

import java.util.Arrays;
import java.util.regex.Pattern;

class Utils {
    private static final String[] IGNORED_KEYWORDS = {"class", "with", "void", "extends", "implements", "extension"};

    static SnippetSelection getSelection(Editor editor) {
        final Document document = editor.getDocument();

        SelectionModel selectionModel = editor.getSelectionModel();

        int offsetL = selectionModel.getSelectionStart();
        int offsetR = selectionModel.getSelectionEnd() - 1;

        if (offsetL <= -1 || offsetR <= -1) {
            return new SnippetSelection();
        }

        final String text = document.getText();

        final String pattern = "[^a-zA-Z]";
        for (int i = text.length() - offsetL; i > 0; i--) {
            if (text.length() <= offsetL) {
                return new SnippetSelection();
            }

            String textOff = getCharString(text.charAt(offsetL));
            if (!textOff.equals(".") && Pattern.matches(pattern, textOff)) {
                offsetL++;

                final int lineNumber = document.getLineNumber(offsetL);
                final String lineText = document.getText(DocumentUtil.getLineTextRange(document, lineNumber));

                if (text.length() <= offsetL || Arrays.stream(IGNORED_KEYWORDS).anyMatch(keyword -> lineText.contains(keyword))) {
                    return new SnippetSelection();
                }

                if (Pattern.matches("[^A-Z]", getCharString(text.charAt(offsetL)))) {
                    return new SnippetSelection(offsetL, offsetR);
                }

                break;
            } else {
                offsetL--;
            }
        }

        int l = 0;
        int r = 0;

        for (int i = text.length() - offsetR; i < text.length(); i++) {
            if (text.length() <= offsetR) {
                return new SnippetSelection();
            }

            final String charStringR = getCharString(text.charAt(offsetR));
            if (charStringR.equals("(")) {
                l++;
            }
            if (charStringR.equals(")")) {
                r++;
            }

            if (r > l || i == text.length()) {
                offsetL = 0;
                offsetR = 0;
                break;
            }

            if (l > 0 && l == r) {
                offsetR++;
                if (!isNextElementValid(text, offsetR)) {
                    offsetL = 0;
                    offsetR = 0;
                }
                break;
            }
            offsetR++;
        }

        return new SnippetSelection(offsetL, offsetR);
    }

    private static boolean isNextElementValid(String code, int length) {
        for (int i = 0; i < 1000; i++) {
            if (code.length() <= length) {
                return false;
            }

            String text = getCharString(code.charAt(length)).trim();
            if (!text.isEmpty()) {
                if (Pattern.matches("[;),\\]]", text)) {
                    return true;
                }
                return false;
            }
            length++;
        }
        return false;
    }

    private static String getCharString(char c) {
        return String.valueOf(c);
    }
}
