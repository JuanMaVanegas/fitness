import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarEjercicios extends StatelessWidget {
  final String titulo;
  final String rutinaId;

  AgregarEjercicios({required this.titulo, required this.rutinaId});

  final List<String> gruposMusculares = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicios'),
      ),
      body: ListView.builder(
        itemCount: gruposMusculares.length,
        itemBuilder: (context, index) {
          return GrupoMuscularItem(
            grupoMuscular: gruposMusculares[index],
            rutinaId: rutinaId,
            titulo: titulo,
          );
        },
      ),
    );
  }
}

class GrupoMuscularItem extends StatelessWidget {
  final String grupoMuscular;
  final String rutinaId;
  final String titulo;

  GrupoMuscularItem(
      {required this.grupoMuscular,
      required this.rutinaId,
      required this.titulo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(grupoMuscular),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EjerciciosPorGrupoMuscular(
              grupoMuscular: grupoMuscular,
              rutinaId: rutinaId,
              titulo: titulo, // Pasar el título aquí
            ),
          ),
        );
      },
    );
  }
}

class EjerciciosPorGrupoMuscular extends StatelessWidget {
  final String grupoMuscular;
  final String rutinaId;
  final String titulo; // Añadir parámetro titulo

  EjerciciosPorGrupoMuscular({
    required this.grupoMuscular,
    required this.rutinaId,
    required this.titulo, // Añadir parámetro titulo
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicios de $grupoMuscular'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Ejercicios')
            .doc(grupoMuscular)
            .collection('lista_ejercicios')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error fetching data: ${snapshot.error}');
            return Center(
                child: Text('Error fetching data. Please try again later.'));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(
              child: Text(
                'No hay ejercicios disponibles para $grupoMuscular',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView(
            children: documents.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String nombre = data['nombre'].toString();
              String dificultad = data['dificultad'].toString();
              String imagenUrl =
                  data['imagen'] != null ? data['imagen'].toString() : '';

              return EjercicioItem(
                nombre: nombre,
                dificultad: dificultad,
                imagenUrl: imagenUrl,
                rutinaId: rutinaId,
                titulo: titulo, // Pasar el título aquí
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class EjercicioItem extends StatelessWidget {
  final String nombre;
  final String dificultad;
  final String imagenUrl;
  final String rutinaId;
  final String titulo;

  EjercicioItem({
    required this.nombre,
    required this.dificultad,
    required this.imagenUrl,
    required this.rutinaId,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        guardarEjercicioEnRutina(context);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Dificultad: $dificultad',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 5),
            if (imagenUrl.isNotEmpty)
              Image.network(
                imagenUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  void guardarEjercicioEnRutina(BuildContext context) {
    print('Iniciando el guardado del ejercicio en la rutina...');

    int series = 3;
    List<int> repeticiones = List.generate(
        series, (index) => 15); 
    int tiempo = 60;

    FirebaseFirestore.instance
        .collection('Rutinas')
        .doc(rutinaId)
        .collection(titulo)
        .add({
      'nombre': nombre,
      'dificultad': dificultad,
      'imagenUrl': imagenUrl,
      'series': series,
      'repeticiones': repeticiones,
      'tiempo': tiempo,
    }).then((value) {
      print('Ejercicio añadido a la rutina');
      Navigator.pop(context);
      print('Navegación realizada con éxito a la pantalla anterior');
    }).catchError((error) {
      print('Error al añadir el ejercicio a la rutina: $error');
    });
  }
}
