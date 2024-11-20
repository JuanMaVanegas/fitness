import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListaRutinasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> diasSemana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Rutinas'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Rutinas').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay rutinas disponibles.'));
          }
          final List<DocumentSnapshot> rutinas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rutinas.length,
            itemBuilder: (context, index) {
              final rutina = rutinas[index];
              return GestureDetector(
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final userRutinasRef = FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user.uid)
                        .collection('MisRutinas')
                        .doc(rutina.id); 
                    for (final dia in diasSemana) {
                      final diaQuerySnapshot = await FirebaseFirestore.instance
                          .collection('Rutinas')
                          .doc(rutina.id)
                          .collection(dia)
                          .get();
                      for (final diaDoc in diaQuerySnapshot.docs) {
                        userRutinasRef.collection(dia).add(diaDoc.data());
                      }
                    }
                    await userRutinasRef.set({
                      'nombre': rutina['nombre'],
                      'imagen': rutina['imagen'],
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rutina agregada con éxito')),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        rutina['imagen'],
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text(
                        rutina['nombre'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
