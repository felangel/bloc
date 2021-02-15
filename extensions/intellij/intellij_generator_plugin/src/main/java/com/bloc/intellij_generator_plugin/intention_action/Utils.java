package com.bloc.intellij_generator_plugin.intention_action;


import com.intellij.openapi.editor.Document;
import com.intellij.openapi.editor.Editor;
import com.intellij.openapi.editor.SelectionModel;
import com.intellij.util.DocumentUtil;

import java.util.regex.Pattern;

class Utils {
    static Selection getSelection(Editor editor) {
        final Document document = editor.getDocument();

        SelectionModel selectionModel = editor.getSelectionModel();

        int offsetL = selectionModel.getSelectionStart();
        int offsetR = selectionModel.getSelectionEnd() - 1;

        final String text = document.getText();

        final String pattern = "[^a-zA-Z]";
        for (int i = text.length() - offsetL; i > 0; i--) {
            String textOff = getCharString(text.charAt(offsetL));
            if (!textOff.equals(".") && Pattern.matches(pattern, textOff)) {
                offsetL++;
                if (Pattern.matches("[^A-Z]", getCharString(text.charAt(offsetL)))) {
                    return new Selection(offsetL, offsetR);
                }

                final int lineNumber = document.getLineNumber(offsetL);
                final String lineText = document.getText(DocumentUtil.getLineTextRange(document, lineNumber));

                if (lineText.indexOf("class") != -1 ||
                        lineText.indexOf("extends") != -1 ||
                        lineText.indexOf("with") != -1 ||
                        lineText.indexOf("implements") != -1 ||
                        lineText.indexOf("=") != -1) {
                    return new Selection(offsetL, offsetR);
                }
                break;
            } else {
                offsetL--;
            }
        }

        int l = 0;
        int r = 0;

        for (int i = text.length() - offsetR; i < text.length(); i++) {
            if (getCharString(text.charAt(offsetR)).equals("(")) {
                l++;
            }
            if (getCharString(text.charAt(offsetR)).equals(")")) {
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

        return new Selection(offsetL, offsetR);
    }

    private static boolean isNextElementValid(String code, int length) {
        for (int i = 0; i < 1000; i++) {
            String text = getCharString(code.charAt(length)).trim();
            if (!text.isEmpty()) {
                if (Pattern.matches("[;),\\]]", text)) {
                    return true;
                } else {
                    return false;
                }
            }
            length++;
        }
        return false;
    }

    private static String getCharString(char c) {
        return String.valueOf(c);
    }
}

class Selection {
    int offsetL;
    int offsetR;

    public Selection(int offsetL, int offsetR) {
        this.offsetL = offsetL;
        this.offsetR = offsetR;
    }
}
