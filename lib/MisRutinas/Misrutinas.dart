import 'package:fitness/MisRutinas/EjerciciosDiaPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MisRutinas extends StatelessWidget {
  final String rutinaId;
  final String nombre;
  final String imagenUrl;

  MisRutinas(
      {required this.rutinaId, required this.nombre, required this.imagenUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                height: 200.0,
                width: double.infinity,
                child: Image.network(
                  imagenUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              nombre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  for (var dayOfWeek in [
                    'Lunes',
                    'Martes',
                    'Miércoles',
                    'Jueves',
                    'Viernes',
                    'Sábado',
                    'Domingo'
                  ])
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('MisRutinas')
                          .doc(rutinaId)
                          .collection(dayOfWeek)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final int ejerciciosCount =
                            snapshot.hasData ? snapshot.data!.docs.length : 0;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EjerciciosDiaPage(
                                  rutinaId: rutinaId,
                                  dayOfWeek: dayOfWeek,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    dayOfWeek.substring(0, 3),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rutina de $dayOfWeek',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$ejerciciosCount ejercicios',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Icon(Icons.more_vert),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}








