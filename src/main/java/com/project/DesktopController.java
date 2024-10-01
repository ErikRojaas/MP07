package com.project;

import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.ListCell;
import javafx.scene.control.ListView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;
import javafx.util.Callback;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class DesktopController {

    @FXML
    private ChoiceBox<String> categoryChoiceBox;

    @FXML
    private ListView<String> itemListView;

    @FXML
    private ImageView itemImageView;

    @FXML
    private Text itemDescription;


    private final String imageFolder = "./src/main/resources/assets/images";

    // Mapa para las descripciones
    private final Map<String, String> descriptions = new HashMap<>();

    // Mapa para los nombres completos
    private final Map<String, String> fullNames = new HashMap<>();

    @FXML
    public void initialize() {
        // Inicializar descripciones y nombres completos
        initializeDescriptions();
        initializeFullNames();

        // Añadir opciones al ChoiceBox desde el controlador
        categoryChoiceBox.setItems(FXCollections.observableArrayList("Personatges", "Jocs", "Consoles"));
        
        // Listener para actualizar los elementos cuando se cambia la categoría
        categoryChoiceBox.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> loadItems(newVal));
        
        // Cargar por defecto la primera categoría
        categoryChoiceBox.setValue("Jocs");

        // Personalizar las celdas del ListView para mostrar imágenes pequeñas
        itemListView.setCellFactory(new Callback<ListView<String>, ListCell<String>>() {
            @Override
            public ListCell<String> call(ListView<String> listView) {
                return new ListCell<>() {
                    private final ImageView imageView = new ImageView();

                    @Override
                    protected void updateItem(String item, boolean empty) {
                        super.updateItem(item, empty);

                        if (empty || item == null) {
                            setText(null);
                            setGraphic(null);
                        } else {
                            // Configura el texto del item
                            String fullName = fullNames.getOrDefault(item, item); // Usa el nombre completo si existe
                            setText(fullName); // Muestra el nombre completo

                            // Establece el tamaño de la imagen
                            imageView.setFitHeight(30);
                            imageView.setFitWidth(30);

                            // Configura la imagen pequeña
                            String category = categoryChoiceBox.getValue();
                            String prefix = getPrefixForCategory(category);
                            String imagePath = imageFolder + "/" + prefix + item + ".png";
                            File imageFile = new File(imagePath);

                            if (imageFile.exists()) {
                                imageView.setImage(new Image(imageFile.toURI().toString()));
                            } else {
                                imageView.setImage(null); // Si no hay imagen, poner nulo
                            }

                            setGraphic(imageView); // Muestra la imagen junto al texto
                        }
                    }
                };
            }
        });
    }

    private void loadItems(String category) {
        String prefix = getPrefixForCategory(category);

        // Lista los archivos en el directorio que coinciden con el prefijo
        File folder = new File(imageFolder);
        File[] files = folder.listFiles((dir, name) -> name.startsWith(prefix) && name.endsWith(".png"));

        itemListView.getItems().clear();
        if (files != null) {
            for (File file : files) {
                // Agrega el nombre del archivo sin el prefijo
                String itemName = file.getName().replace(prefix, "").replace(".png", "");
                itemListView.getItems().add(itemName);
            }
        }

        // Listener para cuando cambie la selección del ListView
        itemListView.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            String currentCategory = categoryChoiceBox.getValue();  // Obtén el valor del ChoiceBox
            loadItemDetails(currentCategory, newVal);  // Pasa la categoría actual a loadItemDetails
        });
    }

    private void loadItemDetails(String category, String itemName) {
        if (itemName == null) return;

        String fullName = fullNames.getOrDefault(itemName, itemName); // Obtiene el nombre completo
        String prefix = getPrefixForCategory(category);
        String imagePath = imageFolder + "/" + prefix + itemName + ".png";
        File imageFile = new File(imagePath);

        if (imageFile.exists()) {
            itemImageView.setImage(new Image(imageFile.toURI().toString()));
        }

        // Muestra el título y la descripción correspondiente
        String description = descriptions.getOrDefault(fullName, "Descripción no disponible.");
        itemDescription.setText(fullName + "\n" + description);
    }

    private String getPrefixForCategory(String category) {
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
        descriptions.put("Pikmin", "Un juego de estrategia y exploración.");
        descriptions.put("Pokémon Red", "Un juego de RPG donde capturas Pokémon.");
        descriptions.put("Super Mario Bros", "El juego que definió el género de plataformas.");
        descriptions.put("Super Mario Kart", "El primer juego de la serie de carreras Mario.");
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
