import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Recetas/detalleRecetaPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Recetas extends StatefulWidget {
  const Recetas({Key? key}) : super(key: key);

  @override
  _RecetasState createState() => _RecetasState();
}

class _RecetasState extends State<Recetas> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _categoriaNameController =
      TextEditingController();
  final TextEditingController _categoriaImageController =
      TextEditingController();

  TextEditingController _duracionController = TextEditingController();
  TextEditingController _porcionesController = TextEditingController();
  TextEditingController _caloriasController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _nuevoIngredienteController = TextEditingController();
  TextEditingController _nuevoPasoController = TextEditingController();
  TextEditingController _pasosController = TextEditingController();

  List<String> _ingredientesList = [];
  List<String> _pasosList = [];

  final CollectionReference _categoria =
      FirebaseFirestore.instance.collection('Categorias');

  final List<Color> colors = [
    Color(0xFFD8A7FF), // Lavanda
    Color(0xFFA7E9FF), // Cian claro
    Color(0xFFFFD6A5), // Albaricoque
    Color(0xFFB6FFB4), // Verde claro
    Color(0xFFFFD8B1), // Melocotón
    Color(0xFFC6FFDD), // Verde menta
    Color(0xFFFFADAD), // Rosa suave3
    Color(0xFFFDFFB6), // Amarillo pastel
    Color(0xFF9BF6FF), // Celeste
    Color(0xFFA0C4FF), // Azul cielo
    Color(0xFFCAF0F8), // Azul turquesa
    Color(0xFFA0E7E5), // Verde azulado
    Color(0xFFBDB2FF), // Morado claro
    Color(0xFFC7CEEA), // Lila
    Color(0xFFFAB1A0), // Coral
    Color(0xFFF9A826), // Naranja claro
    Color(0xFFC5E99B), // Verde pálido
    Color(0xFFFFEEC9), // Crema
    Color(0xFFE1E5E5), // Gris claro
    Color(0xFFE6D1FF), // Lila claro
  ];

  String? _categoriaImageUrlError;
  int? userRoleId;
  String? _selectedCategory;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRoleId();
  }

  Future<void> _fetchUserRoleId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();
        setState(() {
          userRoleId = userDoc['id_rol'];
        });
      } catch (e) {
        print('Error al obtener el id_rol del usuario: $e');
      }
    }
  }

  Future<void> _createCategoria([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _categoriaNameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _categoriaImageController,
                    decoration: InputDecoration(
                      labelText: 'URL de la imagen',
                      errorText: _categoriaImageUrlError,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Crear'),
                    onPressed: () async {
                      final String name = _categoriaNameController.text;
                      final String imageUrl = _categoriaImageController.text;
                      if (_isValidUrl(imageUrl) &&
                          _isValidImageFormat(imageUrl)) {
                        await _categoria
                            .add({"nombre": name, "imagen": imageUrl});
                        _categoriaNameController.text = '';
                        _categoriaImageController.text = '';
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _categoriaImageUrlError =
                              'Por favor, ingresa una URL válida';
                        });
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createReceta([DocumentSnapshot? documentSnapshot]) async {
    QuerySnapshot categoriesSnapshot = await _categoria.get();
    String? _recetaImageUrlError;

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      labelText: 'URL de la imagen',
                      errorText: _recetaImageUrlError,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: categoriesSnapshot.docs
                        .map((DocumentSnapshot document) {
                      return DropdownMenuItem<String>(
                        value: document.id,
                        child: Text(document['nombre']),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: _duracionController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Duración (minutos)'),
                  ),
                  TextField(
                    controller: _porcionesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Porciones'),
                  ),
                  TextField(
                    controller: _caloriasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calorías'),
                  ),
                  TextField(
                    controller: _descripcionController,
                    maxLines: null,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ingredientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _ingredientesList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _ingredientesList.length) {
                        return ListTile(
                          leading: Icon(Icons.add),
                          title: TextField(
                            controller: _nuevoIngredienteController,
                            decoration: InputDecoration(
                                hintText: 'Agregar nuevo ingrediente'),
                            onSubmitted: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  _ingredientesList.add(value);
                                  _nuevoIngredienteController.clear();
                                }
                              });
                            },
                          ),
                        );
                      } else {
                        return CheckboxListTile(
                          title: Text(_ingredientesList[index]),
                          value: false,
                          onChanged: (bool? newValue) {},
                        );
                      }
                    },
                  ),
                  Text(
                    'Paso a paso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pasosList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _pasosList.length) {
                        return ListTile(
                          leading: Icon(Icons.add),
                          title: TextField(
                            controller: _nuevoPasoController,
                            decoration:
                                InputDecoration(hintText: 'Agregar nuevo paso'),
                            onSubmitted: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  _pasosList.add(value);
                                  _nuevoPasoController.clear();
                                }
                              });
                            },
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Text(_pasosList[index]),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Crear'),
                    onPressed: () async {
                      final String name = _nameController.text;
                      final String imageUrl = _imageController.text;
                      final String duracion = _duracionController.text;
                      final String porciones = _porcionesController.text;
                      final String calorias = _caloriasController.text;
                      final String descripcion = _descripcionController.text;
                      final List<String> ingredientes = _ingredientesList;
                      final List<String> pasos = _pasosList;
                      if (name.isNotEmpty &&
                          imageUrl.isNotEmpty &&
                          _selectedCategory != null &&
                          duracion.isNotEmpty &&
                          porciones.isNotEmpty &&
                          calorias.isNotEmpty &&
                          descripcion.isNotEmpty &&
                          ingredientes.isNotEmpty &&
                          pasos.isNotEmpty) {
                        if (_isValidUrl(imageUrl) &&
                            _isValidImageFormat(imageUrl)) {
                          String categoryId = _selectedCategory!;
                          String recetaPath = 'Categorias/$categoryId/Recetas';
                          await FirebaseFirestore.instance
                              .collection(recetaPath)
                              .add({
                            "nombre": name,
                            "imagen": imageUrl,
                            "duracion": duracion,
                            "porciones": porciones,
                            "calorias": calorias,
                            "descripcion": descripcion,
                            "ingredientes": ingredientes,
                            "pasos": pasos,
                          });
                          _nameController.clear();
                          _imageController.clear();
                          _duracionController.clear();
                          _porcionesController.clear();
                          _caloriasController.clear();
                          _descripcionController.clear();
                          _ingredientesList.clear();
                          _pasosController.clear();
                          _pasosList.clear();
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _recetaImageUrlError =
                                'Por favor, ingresa una URL válida';
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Por favor, completa todos los campos.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  bool _isValidUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.isAbsolute;
  }

  bool _isValidImageFormat(String url) {
    String extension = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
  }

  Future<void> _updateCategoria(DocumentSnapshot documentSnapshot) async {
    _categoriaNameController.text = documentSnapshot['nombre'];
    _categoriaImageController.text = documentSnapshot['imagen'].toString();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _categoriaNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _categoriaImageController,
                decoration:
                    const InputDecoration(labelText: 'URL de la imagen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Editar'),
                onPressed: () async {
                  final String name = _categoriaNameController.text;
                  final String imageUrl = _categoriaImageController.text;
                  if (_isValidUrl(imageUrl) && _isValidImageFormat(imageUrl)) {
                    await _categoria
                        .doc(documentSnapshot.id)
                        .update({"nombre": name, "imagen": imageUrl});
                    _categoriaNameController.text = '';
                    _categoriaImageController.text = '';
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'URL de imagen inválida o formato no admitido')),
                    );
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateReceta(DocumentSnapshot documentSnapshot) async {
    final categoriaId = documentSnapshot.reference.parent.parent?.id;

    _nameController.text = documentSnapshot['nombre'];
    _imageController.text = documentSnapshot['imagen'].toString();
    _duracionController.text = documentSnapshot['duracion'].toString();
    _porcionesController.text = documentSnapshot['porciones'].toString();
    _caloriasController.text = documentSnapshot['calorias'].toString();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _duracionController,
                decoration: const InputDecoration(labelText: 'Duración'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _porcionesController,
                decoration: const InputDecoration(labelText: 'Porciones'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _caloriasController,
                decoration: const InputDecoration(labelText: 'Calorías'),
              ),
              TextField(
                keyboardType: TextInputType.url,
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Imagen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Editar'),
                onPressed: () async {
                  final String name = _nameController.text;
                  final String imageUrl = _imageController.text;
                  final String duracion = _duracionController.text;
                  final String porciones = _porcionesController.text;
                  final String calorias = _caloriasController.text;

                  if (_isValidUrl(imageUrl) && _isValidImageFormat(imageUrl)) {
                    final String recetaId = documentSnapshot.id;
                    final String recetaPath =
                        'Categorias/$categoriaId/Recetas/$recetaId';
                    await FirebaseFirestore.instance.doc(recetaPath).update({
                      "nombre": name,
                      "imagen": imageUrl,
                      "duracion": duracion,
                      "porciones": porciones,
                      "calorias": calorias,
                    });
                    _nameController.text = '';
                    _imageController.text = '';
                    _duracionController.text = '';
                    _porcionesController.text = '';
                    _caloriasController.text = '';
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'URL de imagen inválida o formato no admitido')),
                    );
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteCategoria(String categoryId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Categoría'),
          content: Text('¿Estás seguro de que deseas eliminar esta categoría?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategoriaConfirmed(categoryId);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategoriaConfirmed(String categoryId) async {
    await _categoria
        .doc(categoryId)
        .collection('Recetas')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });

    await _categoria.doc(categoryId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has eliminado una categoría con éxito')),
    );
  }

  Future<void> _deleteReceta(DocumentReference recetaRef) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Receta'),
          content: Text('¿Estás seguro de que deseas eliminar esta receta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecetaConfirmed(recetaRef);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecetaConfirmed(DocumentReference recetaRef) async {
    await recetaRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has eliminado una receta con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Recetas')),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar recetas...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collectionGroup('Recetas')
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (streamSnapshot.hasData) {
                    final List<DocumentSnapshot> recetasDocs = streamSnapshot
                        .data!.docs
                        .where((doc) => doc['nombre']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery))
                        .toList();
                    if (recetasDocs.isNotEmpty) {
                      return CarouselSlider.builder(
                        itemCount: recetasDocs.length,
                        itemBuilder: (context, index, realIndex) {
                          final DocumentSnapshot documentSnapshot =
                              recetasDocs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 5),
                            shape: CircleBorder(),
                            child: ClipOval(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.7,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  image: documentSnapshot['imagen'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              documentSnapshot['imagen']
                                                  .toString()),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      documentSnapshot['nombre'].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.3,
                          enlargeCenterPage: true,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          pauseAutoPlayOnTouch: true,
                          onPageChanged: (index, reason) {},
                          scrollDirection: Axis.horizontal,
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No hay Recetas disponibles',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Categorias',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    if (userRoleId == 2)
                      FloatingActionButton(
                        heroTag: 'uniqueTag1',
                        onPressed: () => _createCategoria(),
                        child: const Icon(Icons.category),
                        backgroundColor: Colors.blue,
                      ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: _categoria.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData &&
                      streamSnapshot.data!.docs.isNotEmpty) {
                    return CarouselSlider.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index, realIndex) {
                        final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 5),
                          shape: CircleBorder(),
                          child: ClipOval(
                            child: Container(
                                padding: EdgeInsets.all(16.0),
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.7,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  image: documentSnapshot['imagen'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              documentSnapshot['imagen']
                                                  .toString()),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      documentSnapshot['nombre'].toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (userRoleId == 2)
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.edit),
                                              color: Colors.black,
                                              onPressed: () => _updateCategoria(
                                                  documentSnapshot),
                                            ),
                                          ),
                                        if (userRoleId == 2)
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.delete),
                                              color: Colors.black,
                                              onPressed: () => _deleteCategoria(
                                                  documentSnapshot.id),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.2,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.50,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        pauseAutoPlayOnTouch: true,
                        onPageChanged: (index, reason) {},
                        scrollDirection: Axis.horizontal,
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No hay categorias disponibles',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Recetas',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    if (userRoleId == 2)
                      FloatingActionButton(
                        heroTag: 'uniqueTag2',
                        onPressed: () => _createReceta(),
                        child: const Icon(Icons.add),
                        backgroundColor: Colors.blue,
                      ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collectionGroup('Recetas')
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (streamSnapshot.hasData) {
                          final List<DocumentSnapshot> recetasDocs =
                              streamSnapshot.data!.docs
                                  .where((doc) => doc['nombre']
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchQuery))
                                  .toList();
                          if (streamSnapshot.data!.docs.isNotEmpty) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: recetasDocs.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot documentSnapshot =
                                    recetasDocs[index];

                                final colorIndex = index % colors.length;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetalleRecetaPage(
                                                  documentSnapshot)),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: colors[colorIndex],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                bottomLeft:
                                                    Radius.circular(15.0),
                                              ),
                                              child: documentSnapshot[
                                                          'imagen'] !=
                                                      null
                                                  ? Image.network(
                                                      documentSnapshot['imagen']
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/receta.webp',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      documentSnapshot['nombre']
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  if (userRoleId == 2)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          width: 38,
                                                          height: 38,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                          child: IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            color: Colors.black,
                                                            onPressed: () =>
                                                                _updateReceta(
                                                                    documentSnapshot),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Container(
                                                          width: 38,
                                                          height: 38,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                          child: IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            color: Colors.black,
                                                            onPressed: () =>
                                                                _deleteReceta(
                                                                    documentSnapshot
                                                                        .reference),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No hay recetas disponibles',
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          }
                        } else {
                          return const Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
