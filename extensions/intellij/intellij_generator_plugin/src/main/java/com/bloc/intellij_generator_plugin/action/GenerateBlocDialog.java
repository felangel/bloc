package com.bloc.intellij_generator_plugin.action;

import com.intellij.openapi.ui.DialogWrapper;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

public class GenerateBlocDialog extends DialogWrapper {

    private final Listener listener;
    private JTextField blocNameTextField;
    private JPanel contentPanel;
    private JComboBox<String> style;

    public GenerateBlocDialog(final Listener listener) {
        super(null);
        this.listener = listener;
        init();
    }

    @Nullable
    @Override
    protected JComponent createCenterPanel() {
        return contentPanel;
    }

    @Override
    protected void doOKAction() {
        super.doOKAction();
        BlocTemplateType blocTemplateType;
        final String selectedStyle = style.getSelectedItem().toString();
        if (selectedStyle == "Equatable") {
            blocTemplateType = BlocTemplateType.EQUATABLE;
        } else if (selectedStyle == "Freezed") {
            blocTemplateType = BlocTemplateType.FREEZED;
        } else {
            blocTemplateType = BlocTemplateType.BASIC;
        }
        this.listener.onGenerateBlocClicked(blocNameTextField.getText(), blocTemplateType);
    }

    @Nullable
    @Override
    public JComponent getPreferredFocusedComponent() {
        return blocNameTextField;
    }

    public interface Listener {
        void onGenerateBlocClicked(String blocName, BlocTemplateType blocTemplateType);
    }
}
