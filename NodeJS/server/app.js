const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

// Servir archivos estáticos desde la carpeta 'public' (donde se encuentran las imágenes)
app.use(express.static(path.join(__dirname, '..', 'public')));

// Ruta para obtener todas las categorías
app.get('/api/categories', (req, res) => {
  // Cargar el archivo JSON
  const data = JSON.parse(fs.readFileSync(path.resolve(__dirname, '..', 'private', 'data.json'), 'utf8'));
  res.json(data.categories); // Retorna la lista de categorías
});

// Ruta para obtener los ítems de una categoría específica
app.get('/api/items/:category', (req, res) => {
  const { category } = req.params;
  const data = JSON.parse(fs.readFileSync(path.resolve(__dirname, '..', 'private', 'data.json'), 'utf8'));

  // Filtrar los items que pertenezcan a la categoría solicitada
  const items = data.items.filter(item => item.category.toLowerCase() === category.toLowerCase());

  if (items.length > 0) {
    res.json(items); // Retorna los ítems de esa categoría
  } else {
    res.status(404).json({ message: 'Categoría no encontrada' });
  }
});

// Ruta para obtener un ítem específico por su ID
app.get('/api/items/id/:id', (req, res) => {
  const { id } = req.params;
  const data = JSON.parse(fs.readFileSync(path.resolve(__dirname, '..', 'private', 'data.json'), 'utf8'));

  // Buscar el ítem por su ID
  const item = data.items.find(item => item.id === parseInt(id));

  if (item) {
    res.json(item); // Retorna el ítem con el ID especificado
  } else {
    res.status(404).json({ message: 'Ítem no encontrado' });
  }
});

// Ruta para obtener todos los ítems
app.get('/api/items', (req, res) => {
    const data = JSON.parse(fs.readFileSync(path.resolve(__dirname, '..', 'private', 'data.json'), 'utf8'));
  res.json(data.items); // Retorna todos los ítems
});

// Ruta para obtener la foto de un ítem por su ID
app.get('/api/item/:id/photo', (req, res) => {
  const { id } = req.params;
  const data = JSON.parse(fs.readFileSync(path.resolve(__dirname, '..', 'private', 'data.json'), 'utf8'));

  // Buscar el ítem por su ID
  const item = data.items.find(item => item.id === parseInt(id));

  if (item && item.photo) {
    // Si existe la propiedad 'photo' en el ítem, construir la ruta de la imagen
    const imagePath = path.join(__dirname, '..', 'public', item.photo);

    // Verificar si la imagen existe
    fs.access(imagePath, fs.constants.F_OK, (err) => {
      if (err) {
        return res.status(404).json({ message: 'Imagen no encontrada' });
      }

      // Si la imagen existe, enviarla
      res.sendFile(imagePath);
    });
  } else {
    res.status(404).json({ message: 'Foto no encontrada para este ítem' });
  }
});

// Arrancar el servidor
app.listen(port, () => {
  console.log(`Example app listening on http://localhost:${port}`);
});
