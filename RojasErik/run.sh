#!/bin/bash

# Función para obtener la última versión de un módulo JavaFX
get_latest_version() {
    local module_name=$1
    find ~/.m2/repository/org/openjfx -name "${module_name}-*.jar" | grep -vE "javadoc|sources" | sort -Vr | head -n1
}

# Obtén las rutas más recientes para cada módulo JavaFX
FX_BASE_PATH=$(get_latest_version "javafx-base")
FX_CONTROLS_PATH=$(get_latest_version "javafx-controls")
FX_FXML_PATH=$(get_latest_version "javafx-fxml")
FX_GRAPHICS_PATH=$(get_latest_version "javafx-graphics")

# Configura la variable de entorno con las rutas de los módulos JavaFX
FX_PATH="${FX_BASE_PATH}:${FX_CONTROLS_PATH}:${FX_FXML_PATH}:${FX_GRAPHICS_PATH}"

# Verifica si se encontraron las rutas de los módulos JavaFX
if [[ -z "$FX_PATH" ]]; then
    echo "No se puede encontrar el módulo JavaFX en el repositorio Maven local."
    exit 1
fi

# Configura las opciones de Maven
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --module-path $FX_PATH --add-modules javafx.controls,javafx.fxml,javafx.graphics"

# Opciones específicas para Mac (si corresponde)
if [[ "$OSTYPE" == "darwin"* ]]; then
    export MAVEN_OPTS="$MAVEN_OPTS -Xdock:icon=./target/classes/icons/iconOSX.png"
fi

# Main class desde el primer argumento
mainClass=$1

if [[ -z "$mainClass" ]]; then
    echo "No se especificó la clase principal. Uso: ./run.sh com.project.Main"
    exit 1
fi

echo "Configurando MAVEN_OPTS a: $MAVEN_OPTS"
echo "Clase principal: $mainClass"

# Ejecuta el comando Maven para ejecutar la aplicación
execArg="-Dexec.mainClass=$mainClass"
echo "Argumentos de ejecución: $execArg"

# Ejecuta Maven
mvn clean install exec:java $execArg
