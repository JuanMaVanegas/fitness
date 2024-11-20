import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Rutinas/agregar_ejercicios.dart';

class DetalleEjercicio extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final String rutinaId;
  final int cantidadDocumentos;

  DetalleEjercicio({
    required this.titulo,
    required this.descripcion,
    required this.rutinaId,
    required this.cantidadDocumentos,
  });

  @override
  _DetalleEjercicioState createState() => _DetalleEjercicioState();
}

class _DetalleEjercicioState extends State<DetalleEjercicio> {
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

  Future<void> updateEstadisticas(
      String rutinaId, String titulo, int cantidadDocumentos) async {
    final DocumentReference estadisticasRef = FirebaseFirestore.instance
        .collection('Estadisticas')
        .doc('$rutinaId-$titulo');

    // Obtener el documento de estadísticas correspondiente o crear uno nuevo si no existe
    final DocumentSnapshot estadisticasSnapshot = await estadisticasRef.get();
    if (estadisticasSnapshot.exists) {
      // Actualizar el campo de cantidadDocumentos
      await estadisticasRef.update({'cantidadDocumentos': cantidadDocumentos});
    } else {
      // Crear un nuevo documento de estadísticas
      await estadisticasRef.set({'cantidadDocumentos': cantidadDocumentos});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('/Rutinas/${widget.rutinaId}/${widget.titulo}')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay datos disponibles.'));
          }
          final documentos = snapshot.data!.docs;
          final cantidadDocumentos = documentos.length;
          // Llamar a la función para actualizar las estadísticas
          updateEstadisticas(
              widget.rutinaId, widget.titulo, cantidadDocumentos);
          return ListView.builder(
                padding: EdgeInsets.all(15.0),
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final doc = documentos[index];
              final imagen = doc['imagenUrl'];
              final nombre = doc['nombre'];
              final dificultad = int.tryParse(doc['dificultad'] ?? '0');

              // Widget para mostrar los rayos de dificultad
              Widget _buildDificultadIcon(int dificultad) {
                // Limitamos la dificultad a un rango de 0 a 3
                final limitedDifficulty = dificultad.clamp(0, 3);

                // Color de los rayos basado en la dificultad
                Color rayColor;
                if (limitedDifficulty == 1) {
                  rayColor = Colors.blue; // Fácil
                } else if (limitedDifficulty == 2) {
                  rayColor = Colors.yellow; // Moderado
                } else if (limitedDifficulty == 3) {
                  rayColor = Colors.red; // Difícil
                } else {
                  rayColor =
                      Colors.grey; // Sin dificultad o fuera de rango
                }

                return Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Icon(Icons.flash_on,
                          color: i < limitedDifficulty
                              ? rayColor
                              : Colors.grey),
                  ],
                );
              }

              return Container(
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagen != null) ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0),
                                bottom: Radius.circular(10.0)),
                            child: Container(
                              height:
                                  150.0, 
                              width: double.infinity,
                              child: Image.network(
                                imagen,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    if (nombre != null)
                      Text(
                        nombre,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    if (dificultad != null)
                      _buildDificultadIcon(dificultad),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: userRoleId == 2,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgregarEjercicios(
                    titulo: widget.titulo, rutinaId: widget.rutinaId),
              ),
            );
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
          tooltip: 'Agregar ejercicios',
        ),
      ),
    );
  }
}
