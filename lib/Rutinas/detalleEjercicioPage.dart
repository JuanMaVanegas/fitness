import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleEjercicioPage extends StatelessWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  final String nombre;

  DetalleEjercicioPage(this.documentSnapshot, {required this.nombre});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;
    final String nombreEjercicio = data['nombre'];
    final String imageUrl = data['imagen'];
    final String descripcion = data['descripcion'];
    final String comentarios = data['comentarios'];
    final int dificultad = data['dificultad'] ?? 1;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Detalles del Ejercicio'.toUpperCase(),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '$nombreEjercicio',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Placeholder(),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Descripción:\n',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '$descripcion',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Comentarios:\n',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '$comentarios',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Dificultad:\n',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Nivel $dificultad',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    10), 
                child: LinearProgressIndicator(
                  value: dificultad / 3,
                  minHeight: 10,
                  backgroundColor:
                      Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForDifficulty(dificultad),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForDifficulty(int difficulty) {
    if (difficulty == 1) {
      return Colors.blue;
    } else if (difficulty == 2) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
