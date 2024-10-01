package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ListCell;
import javafx.scene.control.ListView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.util.Callback;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class MobileController {

    @FXML
    private ListView<String> categoryListView;

    @FXML
    private ListView<String> itemListView;

    @FXML
    private Button backButton;

    @FXML
    private Label mobileTitle;

    @FXML
    private VBox itemDetailVBox;

    @FXML
    private ImageView itemImageView;

    @FXML
    private Text itemDescription;

    private final String imageFolder = "./src/main/resources/assets/images";  // Directorio de imágenes

    private final Map<String, String> descriptions = new HashMap<>();  // Mapa para descripciones
    private final Map<String, String> fullNames = new HashMap<>();     // Mapa para nombres completos

    @FXML
    public void initialize() {
        // Inicializar la lista de categorías
        categoryListView.getItems().addAll("Personatges", "Jocs", "Consoles");

        // Listener para cuando se selecciona una categoría
        categoryListView.getSelectionModel().selectedItemProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue != null) {
                showItemsForCategory(newValue);
            }
        });

        // Inicializar nombres completos y descripciones
        initializeFullNames();
        initializeDescriptions();
    }

    private void showItemsForCategory(String category) {
        // Cambiar el título y visibilidad
        mobileTitle.setText(category);
        categoryListView.setVisible(false);
        itemListView.setVisible(true);
        itemDetailVBox.setVisible(false);
        backButton.setVisible(true);

        itemListView.getItems().clear();
    
        // Obtener el prefijo para la categoría seleccionada
        String prefix = getPrefixForCategory(category);
    
        // Lista los archivos en el directorio que coinciden con el prefijo
        File folder = new File(imageFolder);
        File[] files = folder.listFiles((dir, name) -> name.startsWith(prefix) && name.endsWith(".png"));
    
        itemListView.getItems().clear();
        if (files != null) {
            for (File file : files) {
                // Extraer el nombre base del archivo
                String itemName = file.getName().replace(prefix, "").replace(".png", "");
                String fullName = fullNames.getOrDefault(itemName.toLowerCase(), itemName); // Obtiene el nombre completo
    
                // Agregar a la lista usando el nombre completo
                itemListView.getItems().add(fullName);
            }
        }
    
        // Establecer celdas personalizadas en el ListView para mostrar el nombre y la imagen
        itemListView.setCellFactory(new Callback<>() {
            @Override
            public ListCell<String> call(ListView<String> param) {
                return new ListCell<>() {
                    private final ImageView imageView = new ImageView();
                    private final HBox hbox = new HBox(10); // Contenedor para nombre e imagen
    
                    {
                        // Establecer un tamaño predeterminado para las imágenes
                        imageView.setFitHeight(50);
                        imageView.setFitWidth(50);
                        hbox.getChildren().addAll(imageView);  // Agregar ImageView al HBox
                    }
    
                    @Override
                    protected void updateItem(String item, boolean empty) {
                        super.updateItem(item, empty);
                        if (empty || item == null) {
                            setText(null);
                            setGraphic(null);
                        } else {
                            // Establecer el nombre en la celda
                            setText(item);
    
                            // Determinar la clave correspondiente para obtener el prefijo
                            String itemKey = fullNames.entrySet().stream()
                                    .filter(entry -> entry.getValue().equals(item))
                                    .map(Map.Entry::getKey)
                                    .findFirst()
                                    .orElse(item); // Obtiene la clave en minúsculas
    
                            // Generar la ruta del archivo de imagen
                            String imagePath = imageFolder + "/" + prefix + itemKey + ".png";
                            File imageFile = new File(imagePath);
    
                            // Cargar la imagen si existe
                            if (imageFile.exists()) {
                                imageView.setImage(new Image(imageFile.toURI().toString()));
                            } else {
                                imageView.setImage(null); // Si no hay imagen, no mostrar nada
                            }
    
                            setGraphic(hbox); // Configurar HBox como la gráfica de la celda
                        }
                    }
                };
            }
        });
    
        // Listener para cuando se selecciona un elemento de la lista
        itemListView.getSelectionModel().selectedItemProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue != null) {
                showItemDetails(category, newValue);
            }
        });
    }

    private void showItemDetails(String category, String itemName) {
        // Cambiar el título y visibilidad
        String fullName = fullNames.getOrDefault(itemName.toLowerCase(), itemName);
        mobileTitle.setText(fullName);
        itemListView.setVisible(false);
        itemDetailVBox.setVisible(true);

        String itemKey = fullNames.entrySet().stream()
                                    .filter(entry -> entry.getValue().equals(itemName))
                                    .map(Map.Entry::getKey)
                                    .findFirst()
                                    .orElse(itemName);
    
        // Cargar la imagen correspondiente
        String prefix = getPrefixForCategory(category);
        String imagePath = imageFolder + "/" + prefix + itemKey.toLowerCase() + ".png"; // Asegúrate de que el nombre coincida
        File imageFile = new File(imagePath);
        
        // Cargar la imagen si existe
        if (imageFile.exists()) {
            itemImageView.setImage(new Image(imageFile.toURI().toString()));
        } else {
            itemImageView.setImage(null); // Si no hay imagen, no mostrar nada
        }
    
        // Cargar la descripción del ítem
        String description = descriptions.getOrDefault(fullName, "Descripción no disponible.");
        itemDescription.setText(fullName + "\n" + description); // Mostramos el nombre y la descripción
    
        // Asegúrate de que el VBox y los elementos estén visibles
        itemDetailVBox.setVisible(true);
    }

    @FXML
    private void handleBackAction() {
        // Regresar a la vista anterior (lista de categorías o lista de ítems)
        if (itemDetailVBox.isVisible()) {
            itemDetailVBox.setVisible(false);
            itemListView.setVisible(true);
            mobileTitle.setText("Nintendo DB");
        } else if (itemListView.isVisible()) {
            itemListView.setVisible(false);
            categoryListView.setVisible(true);
            backButton.setVisible(false);
            mobileTitle.setText("Nintendo DB");
        }
        
        // Limpiar la selección de los ListViews
        itemListView.getSelectionModel().clearSelection();
        categoryListView.getSelectionModel().clearSelection();  // Limpia la selección en categoryListView
    }

    private String getPrefixForCategory(String category) {
        // Determinar el prefijo del archivo de imagen según la categoría seleccionada
        switch (category) {
            case "Personatges":
                return "character_";
            case "Jocs":
                return "game_";
            case "Consoles":
                return "nintendo_";
            default:
                return "";
        }
    }

    private void initializeDescriptions() {
        descriptions.put("Bowser", "El rey de los Koopas, enemigo de Mario.");
        descriptions.put("Donkey Kong", "Un gran gorila conocido por sus aventuras.");
        descriptions.put("Fox", "El astuto zorro de la serie Star Fox.");
        descriptions.put("Inkling", "Un joven guerrero de tinta de Splatoon.");
        descriptions.put("Kirby", "Un héroe rosa que puede absorber habilidades.");
        descriptions.put("Link", "El valiente héroe de la leyenda de Zelda.");
        descriptions.put("Luigi", "El hermano de Mario, conocido por su valentía.");
        descriptions.put("Mario", "El icónico fontanero de Nintendo.");
        descriptions.put("Olimar", "El capitán del juego Pikmin.");
        descriptions.put("Peach", "La princesa de Mushroom Kingdom.");
        descriptions.put("Pikachu", "El Pokémon eléctrico más famoso.");
        descriptions.put("Samus", "La cazadora de recompensas del universo Metroid.");
        descriptions.put("Toad", "Un leal sirviente de la princesa Peach.");
        descriptions.put("Wario", "El rival de Mario, conocido por su ambición.");

        descriptions.put("Donkey Kong Country", "Un clásico juego de plataformas de SNES.");
        descriptions.put("Metroid", "Un juego de acción y aventura espacial.");
        descriptions.put("Pikmin", "Un juego de estrategia y acción.");
        descriptions.put("Pokémon Red", "El primer juego de la famosa serie Pokémon.");
        descriptions.put("Super Mario Bros", "El clásico juego de plataformas de Mario.");
        descriptions.put("Super Mario Kart", "El primer juego de carreras de Mario.");
        descriptions.put("The Legend of Zelda", "Un juego de aventuras con un mundo vasto.");

        descriptions.put("Nintendo 64", "Una consola de videojuegos de 64 bits.");
        descriptions.put("Nintendo Gamecube", "Una consola de videojuegos de discos mini.");
        descriptions.put("Nintendo NES", "La consola que revitalizó la industria de videojuegos.");
        descriptions.put("Super Nintendo", "Una consola que presentó gráficos en 16 bits.");
        descriptions.put("Nintendo Switch", "Una consola híbrida que combina portátil y de sobremesa.");
        descriptions.put("Nintendo Wii", "Una consola que popularizó los controles de movimiento.");
        descriptions.put("Nintendo WiiU", "La consola que introdujo el GamePad.");
    }

    private void initializeFullNames() {
        // Mapa para los nombres cortos y sus nombres completos
        fullNames.put("bowser", "Bowser");
        fullNames.put("dk", "Donkey Kong");
        fullNames.put("fox", "Fox");
        fullNames.put("inkling", "Inkling");
        fullNames.put("kirby", "Kirby");
        fullNames.put("link", "Link");
        fullNames.put("luigi", "Luigi");
        fullNames.put("mario", "Mario");
        fullNames.put("olimari", "Olimar");
        fullNames.put("peach", "Peach");
        fullNames.put("pikachu", "Pikachu");
        fullNames.put("samus", "Samus");
        fullNames.put("toad", "Toad");
        fullNames.put("wario", "Wario");

        fullNames.put("dkc", "Donkey Kong Country");
        fullNames.put("metroid", "Metroid");
        fullNames.put("pikmin", "Pikmin");
        fullNames.put("pred", "Pokémon Red");
        fullNames.put("smb", "Super Mario Bros");
        fullNames.put("smk", "Super Mario Kart");
        fullNames.put("zelda", "The Legend of Zelda");

        fullNames.put("64", "Nintendo 64");
        fullNames.put("gamecube", "Nintendo Gamecube");
        fullNames.put("nes", "Nintendo NES");
        fullNames.put("sn", "Super Nintendo");
        fullNames.put("switch", "Nintendo Switch");
        fullNames.put("wii", "Nintendo Wii");
        fullNames.put("wiiu", "Nintendo WiiU");
    }
}
