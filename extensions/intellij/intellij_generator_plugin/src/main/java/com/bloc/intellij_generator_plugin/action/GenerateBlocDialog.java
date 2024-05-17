package com.bloc.intellij_generator_plugin.action;

import com.intellij.openapi.ui.DialogWrapper;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;
import java.util.Objects;

public class GenerateBlocDialog extends DialogWrapper {

    private final Listener listener;
    private JTextField blocNameTextField;
    private JPanel contentPanel;
    private JComboBox<String> style;

    public GenerateBlocDialog(final Listener listener) {
        super(false);
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
        final String selectedStyle = Objects.requireNonNull(style.getSelectedItem()).toString();
        if (Objects.equals(selectedStyle, "Equatable")) {
            blocTemplateType = BlocTemplateType.EQUATABLE;
        } else if (Objects.equals(selectedStyle, "Freezed")) {
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
