package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ScrollPane;
import javafx.scene.text.Text;
import javafx.scene.control.TextArea;
import javafx.event.ActionEvent;
import javafx.application.Platform;
import java.net.URL;
import java.util.ResourceBundle;
import javafx.fxml.Initializable;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.InputStream;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.stage.FileChooser;
import javafx.stage.Stage;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.Base64;

import org.json.JSONArray;
import org.json.JSONObject;

public class Controller implements Initializable {

    @FXML
    private Button buttonImage, buttonEnviar, buttonBreak;

    @FXML
    private Text textInfo;
    @FXML
    private ScrollPane scrollPane;

    @FXML
    private TextArea textUser;

    @FXML
    private ImageView img;

    @FXML
    private ImageView user_profile;

    @FXML
    private ImageView ia_profile;

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private CompletableFuture<HttpResponse<InputStream>> streamRequest;
    private CompletableFuture<HttpResponse<String>> completeRequest;
    private AtomicBoolean isCancelled = new AtomicBoolean(false);
    private InputStream currentInputStream;
    private ExecutorService executorService = Executors.newSingleThreadExecutor();
    private Future<?> streamReadingTask;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        setButtonsIdle();

        scrollPane.widthProperty().addListener((obs, oldVal, newVal) -> {
            textInfo.setWrappingWidth(newVal.doubleValue() - 20); // Restar un pequeño margen
        });

        // Cargar imágenes por defecto
        try {
            // Cargar imagen de perfil de usuario
            InputStream userImageStream = getClass().getResourceAsStream("/img/user.png");
            if (userImageStream != null) {
                Image userImage = new Image(userImageStream);
                user_profile.setImage(userImage);
            } else {
                System.out.println("No se pudo cargar la imagen del perfil de usuario.");
            }

            // Cargar imagen de perfil de IA
            InputStream iaImageStream = getClass().getResourceAsStream("/img/llama.png");
            if (iaImageStream != null) {
                Image iaImage = new Image(iaImageStream);
                ia_profile.setImage(iaImage);
            } else {
                System.out.println("No se pudo cargar la imagen del perfil de IA.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void callStream(ActionEvent event) { //Botón enviar
        textInfo.setText(""); // Limpiar textInfo
        setButtonsRunning();
        isCancelled.set(false);

        // Obtener el texto desde textUser y usarlo como prompt
        String prompt = textUser.getText();

        // Variable para almacenar la imagen en base64
        String base64Image = null;

        // Verificar si hay una imagen seleccionada
        if (img.getImage() != null) {
            try {
                // Obtener la imagen desde el ImageView y convertirla a base64
                File imageFile = new File(img.getImage().getUrl().replace("file:", ""));
                BufferedImage bufferedImage = ImageIO.read(imageFile);

                // Convertir la imagen en bytes y luego a base64
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                ImageIO.write(bufferedImage, "png", outputStream);
                byte[] imageBytes = outputStream.toByteArray();
                base64Image = Base64.getEncoder().encodeToString(imageBytes);

                outputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // Determinar el modelo a usar
        String model = (base64Image != null) ? "llava-phi3" : "llama3.2:1b"; // Cambia aquí según la imagen

        // Construir el JSON que enviará el texto (prompt) y la imagen en base64 (si está presente)
        JSONObject jsonRequest = new JSONObject();
        jsonRequest.put("model", model); // Usa el modelo determinado
        jsonRequest.put("prompt", prompt);

        // Si hay una imagen seleccionada, agregarla al JSON
        if (base64Image != null) {
            jsonRequest.put("images", new JSONArray().put(base64Image)); // Asegúrate de usar "images" y no "image"
        }

        // Crear la solicitud HTTP
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:11434/api/generate"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonRequest.toString()))
                .build();

        // Cambiar el texto a "Thinking ..."
        Platform.runLater(() -> textInfo.setText("Thinking ..."));

        streamRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofInputStream())
            .thenApply(response -> {
                //System.out.println("Response Code: " + response.statusCode()); // Imprime el código de estado
                currentInputStream = response.body();
                final boolean[] isFirstLocal = {true}; // Usamos un array para mantener el estado

                streamReadingTask = executorService.submit(() -> {
                    try (BufferedReader reader = new BufferedReader(new InputStreamReader(currentInputStream))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            if (isCancelled.get()) {
                                System.out.println("Stream cancelled");
                                break;
                            }
                            
                            // Imprime la línea de la respuesta para depuración
                            //System.out.println("API Response: " + line);

                            JSONObject jsonResponse = new JSONObject(line);
                            String responseText;

                            // Cambia aquí según la estructura de tu JSON
                            if (jsonResponse.has("data")) {
                                JSONObject data = jsonResponse.getJSONObject("data");
                                responseText = data.has("response") ? data.getString("response") : "No response available.";
                            } else {
                                responseText = jsonResponse.has("response") ? jsonResponse.getString("response") : "No response available.";
                            }

                            // Usar variable local para controlar el flujo
                            if (isFirstLocal[0]) {
                                Platform.runLater(() -> {
                                    textInfo.setText(responseText);
                                    textUser.clear(); // Limpiar el TextArea después de recibir la respuesta
                                    img.setImage(null); // Borrar la imagen después de la respuesta
                                });
                                isFirstLocal[0] = false; // Cambiar el estado a no es el primero
                            } else {
                                Platform.runLater(() -> textInfo.setText(textInfo.getText() + responseText));
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Platform.runLater(() -> {
                            textInfo.setText("Error during streaming.");
                            setButtonsIdle();
                        });
                    } finally {
                        try {
                            if (currentInputStream != null) {
                                System.out.println("Cancelling InputStream in finally");
                                currentInputStream.close();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        Platform.runLater(this::setButtonsIdle);
                    }
                });
                return response;
            })
            .exceptionally(e -> {
                if (!isCancelled.get()) {
                    e.printStackTrace();
                }
                Platform.runLater(this::setButtonsIdle);
                return null;
            });
    }



    @FXML
    private void callBreak(ActionEvent event) {
        isCancelled.set(true);
        cancelStreamRequest();
        cancelCompleteRequest();
        Platform.runLater(() -> {
            textInfo.setText("Respuesta Cancelada.");
            setButtonsIdle();
        });
    }

    @FXML
    private void callImage() {
        File initialDirectory = new File("./");
        FileChooser fileChooser = new FileChooser();
        if (initialDirectory.exists()) {
            fileChooser.setInitialDirectory(initialDirectory);
        }
        fileChooser.getExtensionFilters().addAll(
            new FileChooser.ExtensionFilter("Image Files", "*.png", "*.jpg", "*.jpeg")
        );
        
        Stage stage = (Stage) buttonImage.getScene().getWindow();
        File selectedFile = fileChooser.showOpenDialog(stage);

        if (selectedFile != null) {
            try {
                // Read the image file
                BufferedImage bufferedImage = ImageIO.read(selectedFile);

                // Create a ByteArrayOutputStream to store the image bytes
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

                // Write the image to the output stream in PNG format
                ImageIO.write(bufferedImage, "png", outputStream);

                // Set the image in the ImageView
                Image image = new Image(selectedFile.toURI().toString());
                img.setImage(image);

                outputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void cancelStreamRequest() {
        if (streamRequest != null && !streamRequest.isDone()) {
            try {
                if (currentInputStream != null) {
                    System.out.println("Cancelling InputStream");
                    currentInputStream.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            System.out.println("Cancelling StreamRequest");
            if (streamReadingTask != null) {
                streamReadingTask.cancel(true);
            }
            streamRequest.cancel(true);
        }
    }

    private void cancelCompleteRequest() {
        if (completeRequest != null && !completeRequest.isDone()) {
            System.out.println("Cancelling CompleteRequest");
            completeRequest.cancel(true);
        }
    }

    private void setButtonsRunning() {
        buttonEnviar.setDisable(true);
        buttonBreak.setDisable(false);
    }

    private void setButtonsIdle() {
        buttonEnviar.setDisable(false);
        buttonBreak.setDisable(true);
        streamRequest = null;
        completeRequest = null;
    }
}
