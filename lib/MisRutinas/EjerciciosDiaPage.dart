import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/MisRutinas/EditarEjercicio.dart';
import 'package:fitness/MisRutinas/EntrenamientoPage.dart';
import 'package:flutter/material.dart';

class EjerciciosDiaPage extends StatefulWidget {
  final String rutinaId;
  final String dayOfWeek;

  EjerciciosDiaPage({required this.rutinaId, required this.dayOfWeek});

  @override
  _EjerciciosDiaPageState createState() => _EjerciciosDiaPageState();
}

class _EjerciciosDiaPageState extends State<EjerciciosDiaPage> {
  List<DocumentSnapshot> ejercicios = [];

  @override
  void initState() {
    super.initState();
    loadEjercicios();
  }

  Future<void> loadEjercicios() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('MisRutinas')
        .doc(widget.rutinaId)
        .collection(widget.dayOfWeek)
        .get();

    setState(() {
      ejercicios = snapshot.docs.toList();
    });
  }

  Future<void> eliminarEjercicio(String ejercicioId) async {
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('MisRutinas')
        .doc(widget.rutinaId)
        .collection(widget.dayOfWeek)
        .doc(ejercicioId);

    try {
      await docRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ejercicio eliminado'),
        ),
      );
      loadEjercicios();
    } catch (e) {
      print('Error al eliminar el ejercicio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el ejercicio'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicios del ${widget.dayOfWeek}'),
      ),
      body: ejercicios.isEmpty
          ? Center(
              child: Text(
                  'No hay ejercicios disponibles para ${widget.dayOfWeek}.'),
            )
          : ListView.builder(
              itemCount: ejercicios.length,
              itemBuilder: (context, index) {
                final ejercicio = ejercicios[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10.0),
                        bottom: Radius.circular(10.0)),
                    child: Container(
                      child: Image.network(
                        ejercicio['imagenUrl'],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(ejercicio['nombre']),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarEjercicioPage(
                                  rutinaId: widget.rutinaId,
                                  dayOfWeek: widget.dayOfWeek,
                                  ejercicioId: ejercicio.id,
                                  nombre: ejercicio['nombre'],
                                  imagenUrl: ejercicio['imagenUrl'],
                                  series: ejercicio['series'],
                                  tiempo: ejercicio['tiempo'],
                                  repeticiones:
                                      List<int>.from(ejercicio['repeticiones']),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Eliminar'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('¿Estás seguro?'),
                                content: Text(
                                  '¿Seguro que deseas eliminar este ejercicio?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await eliminarEjercicio(ejercicio.id);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (ejercicios.isNotEmpty) {
            List<Map<String, dynamic>> ejerciciosData = ejercicios
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntrenamientoPage(
                  rutinaId: widget.rutinaId,
                  dayOfWeek: widget.dayOfWeek,
                  ejercicios: ejerciciosData,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'No hay ejercicios disponibles para iniciar el entrenamiento.'),
              ),
            );
          }
        },
        heroTag: 'uniqueTag10',
        label: Text('Iniciar entrenamiento'),
        icon: Icon(Icons.directions_run),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
