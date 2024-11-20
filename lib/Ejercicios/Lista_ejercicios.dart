import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Rutinas/detalleEjercicioPage.dart';
import 'package:flutter/material.dart';

class DetEjercicios extends StatefulWidget {
  final String nombre;

  const DetEjercicios({Key? key, required this.nombre}) : super(key: key);

  @override
  _DetEjerciciosState createState() => _DetEjerciciosState();
}

class _DetEjerciciosState extends State<DetEjercicios> {
  TextEditingController _nameExerciseController = TextEditingController();
  TextEditingController _imageExerciseController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _comentariosController = TextEditingController();

  int? _selectedDifficulty;
  int? dificultad = 1;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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
  int? userRoleId;

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

  Future<void> _createEjercicio([DocumentSnapshot? documentSnapshot]) async {
    try {
      String? _ejercicioImageUrlError;
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
                    controller: _nameExerciseController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _imageExerciseController,
                    decoration: InputDecoration(
                      labelText: 'URL de la imagen',
                      errorText: _ejercicioImageUrlError,
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    value: _selectedDifficulty,
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDifficulty = newValue;
                      });
                    },
                    items:
                        <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Dificultad'),
                  ),
                  TextField(
                    controller: _descripcionController,
                    maxLines: null,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: _comentariosController,
                    maxLines: null,
                    decoration: const InputDecoration(labelText: 'Comentarios'),
                  ),
                  ElevatedButton(
                    child: const Text('Crear'),
                    onPressed: () async {
                      final String name = _nameExerciseController.text;
                      final String imageUrl = _imageExerciseController.text;
                      final String descripcion = _descripcionController.text;
                      final String comentarios = _descripcionController.text;

                      if (name.isNotEmpty &&
                          imageUrl.isNotEmpty &&
                          descripcion.isNotEmpty &&
                          comentarios.isNotEmpty &&
                          _selectedDifficulty != null) {
                        if (_isValidUrl(imageUrl) &&
                            _isValidImageFormat(imageUrl)) {
                          String ejercicioPath =
                              'Ejercicios/${widget.nombre}/lista_ejercicios';
                          await FirebaseFirestore.instance
                              .collection(ejercicioPath)
                              .add({
                            "nombre": name,
                            "imagen": imageUrl,
                            "descripcion": descripcion,
                            "comentarios": comentarios,
                            "dificultad": _selectedDifficulty,
                          });
                          _nameExerciseController.clear();
                          _imageExerciseController.clear();
                          _descripcionController.clear();
                          _comentariosController.clear();
                          _selectedDifficulty = null;
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _ejercicioImageUrlError =
                                'Por favor, ingresa una URL válida';
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, completa todos los campos y selecciona una dificultad.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error al crear el ejercicio: $e');
    }
  }

  bool _isValidUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.isAbsolute;
  }

  bool _isValidImageFormat(String url) {
    String extension = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  Future<void> _updateEjercicio(DocumentSnapshot documentSnapshot) async {
    try {
      _nameExerciseController.text = documentSnapshot['nombre'];
      _imageExerciseController.text =
          documentSnapshot.exists ? documentSnapshot['imagen'].toString() : '';
      _descripcionController.text = documentSnapshot.exists
          ? documentSnapshot['descripcion'].toString()
          : '';
      _comentariosController.text = documentSnapshot.exists
          ? documentSnapshot['comentarios'].toString()
          : '';

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
                  controller: _nameExerciseController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  keyboardType: TextInputType.url,
                  controller: _imageExerciseController,
                  decoration: const InputDecoration(labelText: 'Imagen'),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedDifficulty,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedDifficulty = newValue;
                    });
                  },
                  items: <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Dificultad'),
                ),
                TextField(
                  controller: _descripcionController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _comentariosController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Comentarios'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Editar'),
                  onPressed: () async {
                    final String name = _nameExerciseController.text;
                    final String imageUrl = _imageExerciseController.text;
                    final String descripcion = _descripcionController.text;
                    final String comentarios = _comentariosController.text;

                    if (_isValidUrl(imageUrl) &&
                        _isValidImageFormat(imageUrl)) {
                      final String ejercicioPath =
                          'Ejercicios/${widget.nombre}/lista_ejercicios/${documentSnapshot.id}';

                      await FirebaseFirestore.instance
                          .doc(ejercicioPath)
                          .update({
                        "nombre": name,
                        "imagen": imageUrl,
                        "dificultad": _selectedDifficulty,
                        "descripcion": descripcion,
                        "comentarios": comentarios,
                      });
                      _nameExerciseController.text = '';
                      _imageExerciseController.text = '';
                      _selectedDifficulty = null;
                      _descripcionController.text = '';
                      _comentariosController.text = '';
                      Navigator.of(ctx).pop();
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'URL de imagen inválida o formato no admitido'),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error al actualizar el ejercicio: $e');
    }
  }

  Future<void> _deleteEjercicio(DocumentReference ejercicioRef) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Ejercicio'),
          content: Text('¿Estás seguro de que deseas eliminar esta ejercicio?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEjercicioConfirmed(ejercicioRef);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEjercicioConfirmed(DocumentReference ejercicioRef) async {
    await ejercicioRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has eliminado una ejercicio con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Detalles del ejercicio')),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ejercicios...',
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Ejercicios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  if (userRoleId == 2)
                    FloatingActionButton(
                      heroTag: 'ButttonCrearEjercicio',
                      onPressed: () => _createEjercicio(),
                      child: const Icon(Icons.add),
                      backgroundColor: Colors.blue,
                    ),
                ],
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Ejercicios')
                  .doc(widget.nombre)
                  .collection('lista_ejercicios')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (streamSnapshot.hasData) {
                  final List<DocumentSnapshot> ejerciciosDocs = streamSnapshot
                      .data!.docs
                      .where((doc) => doc['nombre']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery))
                      .toList();
                  if (streamSnapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: ejerciciosDocs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            ejerciciosDocs[index];
                        if (!documentSnapshot.exists) {
                          return Container();
                        }

                        final colorIndex = index % colors.length;
                        dificultad = documentSnapshot['dificultad'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleEjercicioPage(
                                  documentSnapshot,
                                  nombre: widget.nombre,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: colors[colorIndex],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        bottomLeft: Radius.circular(15.0),
                                      ),
                                      child: (() {
                                        final data = documentSnapshot.data()
                                            as Map<String, dynamic>;
                                        if (data.containsKey('imagen') &&
                                            data['imagen'] != null) {
                                          return Image.network(
                                            data['imagen'].toString(),
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          return Image.asset(
                                            'assets/exercise.png',
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      })(),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Center(
                                            child: Text(
                                              documentSnapshot['nombre']
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          if (userRoleId == 2)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
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
                                                    onPressed: () =>
                                                        _updateEjercicio(
                                                            documentSnapshot),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
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
                                                    onPressed: () =>
                                                        _deleteEjercicio(
                                                            documentSnapshot
                                                                .reference),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          SizedBox(height: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Dificultad',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: dificultad! >= 1
                                                          ? Colors.blue
                                                          : Colors.grey,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '1',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: dificultad! >= 2
                                                          ? Colors.blue
                                                          : Colors.grey,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '2',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: dificultad! >= 3
                                                          ? Colors.blue
                                                          : Colors.grey,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '3',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                        'No hay ejercicios disponibles',
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
      ),
    );
  }
}
