package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.DialogPane;
import javafx.event.ActionEvent;

public class Controller {

    @FXML
    private DialogPane barra;

    private StringBuilder input = new StringBuilder();
    private String operator = "";
    private double firstOperand = 0;

    @FXML
private void handleNumberButtonAction(ActionEvent event) {
    Button source = (Button) event.getSource();
    String buttonText = source.getText();
    input.append(buttonText);
    
    barra.setContentText(input.toString());
}

    @FXML
    private void handleOperatorButtonAction(ActionEvent event) {
        Button source = (Button) event.getSource();
        String buttonText = source.getText();

        if (input.length() > 0) {
            firstOperand = Double.parseDouble(input.toString());
            input.setLength(0); // Clear input
        }

        operator = buttonText;
    }

    @FXML
    private void handleEqualsButtonAction(ActionEvent event) {
        if (input.length() > 0 && !operator.isEmpty()) {
            double secondOperand = Double.parseDouble(input.toString());
            double result = 0;

            switch (operator) {
                case "+":
                    result = firstOperand + secondOperand;
                    break;
                case "-":
                    result = firstOperand - secondOperand;
                    break;
                case "X":
                    result = firstOperand * secondOperand;
                    break;
                case "÷":
                    result = firstOperand / secondOperand;
                    break;
            }

            input.setLength(0);
            input.append(result);
            barra.setContentText(input.toString());
            operator = "";
        }
    }

    @FXML
    private void handleClearButtonAction(ActionEvent event) {
        input.setLength(0);
        operator = "";
        barra.setContentText("");
    }

    @FXML
    private void handleDeleteButtonAction(ActionEvent event) {
        if (input.length() > 0) {
            input.setLength(input.length() - 1);
            barra.setContentText(input.toString());
        }
    }
}
