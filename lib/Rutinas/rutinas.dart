import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Rutinas/detalleRutinaPage.dart';
import 'package:flutter/material.dart';

class DetRutinas extends StatefulWidget {
  const DetRutinas({Key? key}) : super(key: key);

  @override
  _DetRutinasState createState() => _DetRutinasState();
}

class _DetRutinasState extends State<DetRutinas> {
  TextEditingController _nameRutinaController = TextEditingController();
  TextEditingController _imageRutinaController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();

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

  Future<void> _createRutina([DocumentSnapshot? documentSnapshot]) async {
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
                    controller: _nameRutinaController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _imageRutinaController,
                    decoration: InputDecoration(
                      labelText: 'URL de la imagen',
                      errorText: _ejercicioImageUrlError,
                    ),
                  ),
                  TextField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  ElevatedButton(
                    child: const Text('Crear'),
                    onPressed: () async {
                      final String name = _nameRutinaController.text;
                      final String imageUrl = _imageRutinaController.text;
                      final String descripcion = _descripcionController.text;

                      if (name.isNotEmpty &&
                          imageUrl.isNotEmpty &&
                          descripcion.isNotEmpty) {
                        if (_isValidUrl(imageUrl) &&
                            _isValidImageFormat(imageUrl)) {
                          String rutinaId = FirebaseFirestore.instance
                              .collection('Rutinas')
                              .doc()
                              .id;
                          await FirebaseFirestore.instance
                              .collection('Rutinas')
                              .doc(rutinaId)
                              .set({
                            "nombre": name,
                            "imagen": imageUrl,
                            "descripcion": descripcion,
                          });
                          _nameRutinaController.clear();
                          _imageRutinaController.clear();
                          _descripcionController.clear();
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
        },
      );
    } catch (e) {
      print('Error al crear la rutina: $e');
    }
  }

  bool _isValidUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.isAbsolute;
  }

  bool _isValidImageFormat(String url) {
    String extension = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
  }

  Future<void> _updateRutina(DocumentSnapshot documentSnapshot) async {
    try {
      _nameRutinaController.text = documentSnapshot['nombre'];
      _imageRutinaController.text =
          documentSnapshot.exists ? documentSnapshot['imagen'].toString() : '';
      _descripcionController.text = documentSnapshot.exists
          ? documentSnapshot['descripcion'].toString()
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
                  controller: _nameRutinaController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  keyboardType: TextInputType.url,
                  controller: _imageRutinaController,
                  decoration: const InputDecoration(labelText: 'Imagen'),
                ),
                TextField(
                  controller: _descripcionController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Editar'),
                  onPressed: () async {
                    final String name = _nameRutinaController.text;
                    final String imageUrl = _imageRutinaController.text;
                    final String descripcion = _descripcionController.text;

                    if (_isValidUrl(imageUrl) &&
                        _isValidImageFormat(imageUrl)) {
                      final String rutinaId = documentSnapshot.id;

                      await FirebaseFirestore.instance
                          .collection('Rutinas')
                          .doc(rutinaId)
                          .update({
                        "nombre": name,
                        "imagen": imageUrl,
                        "descripcion": descripcion,
                      });
                      _nameRutinaController.text = '';
                      _imageRutinaController.text = '';
                      _descripcionController.text = '';
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
      print('Error al actualizar la rutina: $e');
    }
  }

  Future<void> _deleteRutina(DocumentReference rutinaRef) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Rutina'),
          content: Text('¿Estás seguro de que deseas eliminar esta rutina?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRutinaConfirmed(rutinaRef);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRutinaConfirmed(DocumentReference rutinaRef) async {
    await rutinaRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has eliminado una rutina con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar rutinas...',
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
                    'Rutinas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  if (userRoleId == 2)
                    FloatingActionButton(
                      heroTag: 'ButttonCrearRutina',
                      onPressed: () => _createRutina(),
                      child: const Icon(Icons.add),
                      backgroundColor: Colors.blue,
                    ),
                ],
              ),
            ),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Rutinas').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (streamSnapshot.hasData) {
                  final List<DocumentSnapshot> rutinasDocs = streamSnapshot
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
                      itemCount: rutinasDocs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              rutinasDocs[index];
                        if (!documentSnapshot.exists) {
                          return Container();
                        }

                        final colorIndex = index % colors.length;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RutinaDetailPage(
                                    documentSnapshot: documentSnapshot),
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
                                                        _updateRutina(
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
                                                        _deleteRutina(
                                                            documentSnapshot
                                                                .reference),
                                                  ),
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
                        'No hay rutinas disponibles',
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
