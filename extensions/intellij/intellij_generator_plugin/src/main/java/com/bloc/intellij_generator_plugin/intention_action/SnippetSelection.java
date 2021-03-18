package com.bloc.intellij_generator_plugin.intention_action;

class SnippetSelection {
    private final int offsetL;
    private final int offsetR;

    private final boolean isValid;

    public SnippetSelection(int offsetL, int offsetR) {
        if (offsetL >= offsetR) {
            this.offsetL = -1;
            this.offsetR = 0;
            this.isValid = false;
        } else {
            this.offsetL = offsetL;
            this.offsetR = offsetR;
            this.isValid = true;
        }
    }

    public SnippetSelection() {
        this.offsetL = -1;
        this.offsetR = 0;
        this.isValid = false;
    }

    public int getOffsetL() {
        return offsetL;
    }

    public int getOffsetR() {
        return offsetR;
    }

    public boolean isValid() {
        return isValid;
    }
}
