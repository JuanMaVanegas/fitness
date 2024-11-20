import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/MisRutinas/ContadorRegresivo.dart';
import 'package:flutter/material.dart';

class EntrenamientoPage extends StatefulWidget {
  final String rutinaId;
  final String dayOfWeek;
  final List<Map<String, dynamic>> ejercicios;

  EntrenamientoPage({
    required this.rutinaId,
    required this.dayOfWeek,
    required this.ejercicios,
  });

  @override
  _EntrenamientoPageState createState() => _EntrenamientoPageState();
}

class _EntrenamientoPageState extends State<EntrenamientoPage> {
  int indiceSerieActual = 0;
  int indiceEjercicioActual = 0;

  void terminarSerie() {
  setState(() {
    indiceSerieActual++;
    if (indiceSerieActual >= widget.ejercicios[indiceEjercicioActual]['series']) {
      indiceSerieActual = 0;
      indiceEjercicioActual++; 
    }
  });

  if (indiceEjercicioActual >= widget.ejercicios.length) {
    guardarDiasEntrenamiento(DateTime.now()); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has completado todos los ejercicios.'),
      ),
    );
  }
}


  void guardarDiasEntrenamiento(DateTime fecha) async {
    try {
      final progresoCollectionRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('progreso');

      final doc = await progresoCollectionRef.doc('entrenamientos').get();
      final diasEntrenamientoActual = doc.exists
          ? doc['dias_entrenamiento'] ?? 0
          : 0; 

      final nuevoValor = diasEntrenamientoActual + 1;

      await progresoCollectionRef.doc('entrenamientos').set({
        'dias_entrenamiento': nuevoValor,
        'ultima_actualizacion': DateTime.now(),
        'fechas_entrenamiento': FieldValue.arrayUnion([fecha]),
      });

      print('Número de días de entrenamiento actualizado a $nuevoValor');
    } catch (e) {
      print('Error al guardar los días de entrenamiento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (indiceEjercicioActual >= widget.ejercicios.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Entrenamiento'),
        ),
        body: Center(
          child: Text(
            'Has completado todos los ejercicios',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    final ejercicioActual = widget.ejercicios[indiceEjercicioActual];
    final tiempoEjercicioActual = ejercicioActual['tiempo'];
    final repeticionesEjercicioActual =
        List<int>.from(ejercicioActual['repeticiones']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenamiento'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              ejercicioActual['imagenUrl'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            ejercicioActual['nombre'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Serie: ${indiceSerieActual + 1}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 20),
              Text(
                'Repeticiones: ${repeticionesEjercicioActual[indiceSerieActual]}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContadorRegresivoPage(
                    tiempo: tiempoEjercicioActual,
                    onCountdownFinished: () {
                      terminarSerie();
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: Text('Terminar serie'),
          ),
        ],
      ),
    );
  }
}
