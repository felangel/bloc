package com.bloc.intellij_generator_plugin.intention_action;

class SnippetSelection {
    int offsetL;
    int offsetR;

    boolean isValid;

    public SnippetSelection(int offsetL, int offsetR) {
        this.offsetL = offsetL;
        this.offsetR = offsetR;
        this.isValid = true;
    }

    public SnippetSelection() {
        this.offsetL = -1;
        this.offsetR = 0;
        this.isValid = false;
    }
}
