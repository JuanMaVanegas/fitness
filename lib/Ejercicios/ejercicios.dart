import 'package:fitness/Ejercicios/Lista_ejercicios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ejercicios extends StatelessWidget {
  final List<String> nombres = [
    'Pecho',
    'Espalda',
    'Bíceps',
    'Tríceps',
    'Abdomen',
    'Glúteos',
    'Cuádriceps',
    'Isquiotibiales',
    'Hombros',
    'Pantorilla'
  ];

  final List<ImageProvider> imagenes = [
    AssetImage('assets/pecho.png'),
    AssetImage('assets/espalda.png'),
    AssetImage('assets/biceps.png'),
    AssetImage('assets/triceps.png'),
    AssetImage('assets/abdomen.png'),
    AssetImage('assets/gluteos.png'),
    AssetImage('assets/cuadriceps.png'),
    AssetImage('assets/isquiotibiales.png'),
    AssetImage('assets/hombros.png'),
    AssetImage('assets/pantorrillas.png'),
  ];

  final CollectionReference ejercicios =
      FirebaseFirestore.instance.collection('Ejercicios');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Text(
              'Ejercicios',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            )),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  final int firstIndex = index * 2;
                  final int secondIndex = firstIndex + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildContainerWithImageAndName(
                            context,
                            imagenes[firstIndex],
                            nombres[firstIndex],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildContainerWithImageAndName(
                            context,
                            imagenes[secondIndex],
                            nombres[secondIndex],
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
      ),
    );
  }

  Widget _buildContainerWithImageAndName(
      BuildContext context, ImageProvider imagen, String nombre) {
    return GestureDetector(
      
      onTap: () {
        _saveToFirestore(nombre);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetEjercicios(nombre: nombre),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image(
                image: imagen,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              nombre,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToFirestore(String nombre) async {
    await ejercicios.doc(nombre);
  }
}


