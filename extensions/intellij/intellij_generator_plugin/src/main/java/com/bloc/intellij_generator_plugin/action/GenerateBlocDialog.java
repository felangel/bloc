package com.bloc.intellij_generator_plugin.action;

import com.intellij.openapi.ui.DialogWrapper;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

public class GenerateBlocDialog extends DialogWrapper {

    private final Listener listener;
    private JTextField blocNameTextField;
    private JPanel contentPanel;
    private JRadioButton useEquatable;
    private JRadioButton useFreezed;
    private JRadioButton useNone;

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
        if (useEquatable.isSelected()) {
            blocTemplateType = BlocTemplateType.EQUATABLE;
        } else if (useFreezed.isSelected()) {
            blocTemplateType = BlocTemplateType.FREEZED;
        } else if (useNone.isSelected()) {
            blocTemplateType = BlocTemplateType.NONE;
        } else {
            blocTemplateType = BlocTemplateType.NONE;
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
