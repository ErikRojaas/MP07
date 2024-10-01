package com.project;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;

public class MainController extends Application {

    private static final double MOBILE_THRESHOLD_WIDTH = 600; // Ancho para cambiar a la vista móvil
    private Scene scene;
    private Parent desktopView;
    private Parent mobileView;

    @Override
    public void start(Stage primaryStage) throws Exception {
        // Cargar las dos vistas FXML (layout.fxml y mobile_layout.fxml)
        desktopView = FXMLLoader.load(getClass().getResource("/assets/layout.fxml"));
        mobileView = FXMLLoader.load(getClass().getResource("/assets/mobile_layout.fxml"));

        // Usar la vista de escritorio como vista predeterminada
        scene = new Scene(desktopView, 800, 600); // Configura la vista inicial para escritorio
        primaryStage.setScene(scene);
        primaryStage.setTitle("JavaFX App");
        primaryStage.show();

        // Listener para detectar cambios de tamaño de la ventana
        scene.widthProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                // Cambiar a la vista móvil si el ancho es menor al umbral
                if (newValue.doubleValue() < MOBILE_THRESHOLD_WIDTH) {
                    scene.setRoot(mobileView);
                } else {
                    // Volver a la vista de escritorio si el ancho es mayor
                    scene.setRoot(desktopView);
                }
            }
        });
    }

    public static void main(String[] args) {
        launch(args);
    }
}
