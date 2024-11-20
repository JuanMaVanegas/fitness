import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditarEjercicioPage extends StatefulWidget {
  final String rutinaId;
  final String ejercicioId;
  final String nombre;
  final String imagenUrl;
  int series;
  int tiempo;
  final List<int> repeticiones;
  final String dayOfWeek;

  EditarEjercicioPage({
    required this.rutinaId,
    required this.ejercicioId,
    required this.nombre,
    required this.imagenUrl,
    required this.series,
    required this.tiempo,
    required this.repeticiones,
    required this.dayOfWeek,
  });

  @override
  _EditarEjercicioPageState createState() => _EditarEjercicioPageState();
}

class _EditarEjercicioPageState extends State<EditarEjercicioPage> {
  late List<int> repeticionesPorSerie;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de repeticiones con las repeticiones existentes
    repeticionesPorSerie = List<int>.from(widget.repeticiones as Iterable);
  }

  void _agregarSerie() {
    setState(() {
      // Agrega una serie con repeticiones por defecto
      repeticionesPorSerie.add(15); // Cambia 15 por el valor deseado
      widget.series++; // Incrementa el número de series
    });
  }

  Future<void> _guardarCambios() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario no autenticado'),
        ),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('MisRutinas')
        .doc(widget.rutinaId)
        .collection(widget.dayOfWeek)
        .doc(widget.ejercicioId);

    try {
      await docRef.update({
        'nombre': widget.nombre,
        'imagenUrl': widget.imagenUrl,
        'series': widget.series,
        'tiempo': widget.tiempo,
        'repeticiones':
            repeticionesPorSerie, // Actualiza la lista de repeticiones
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ejercicio actualizado exitosamente'),
        ),
      );
    } catch (e) {
      print('Error al actualizar el ejercicio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el ejercicio: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Ejercicio'),
        actions: [
          TextButton(
            onPressed: () async {
              await _guardarCambios();
              Navigator.of(context)
                  .pop(); // Vuelve a la página anterior después de guardar
            },
            child: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                widget.imagenUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${widget.nombre}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: repeticionesPorSerie.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(repeticionesPorSerie[index].toString()),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      setState(() {
                        if (direction == DismissDirection.startToEnd) {
                          repeticionesPorSerie[index]++;
                        } else if (direction == DismissDirection.endToStart) {
                          if (repeticionesPorSerie[index] > 0) {
                            repeticionesPorSerie[index]--;
                          }
                        }
                      });
                    },
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.add),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.remove),
                    ),
                    child: ListTile(
                      title: Text(
                        'Serie ${index + 1}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Repeticiones: ${repeticionesPorSerie[index]}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(width: 12),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                repeticionesPorSerie.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        int minutos = widget.tiempo ~/ 60;
                        int segundos = widget.tiempo % 60;
                        TextEditingController minutosController =
                            TextEditingController(text: minutos.toString());
                        TextEditingController segundosController =
                            TextEditingController(text: segundos.toString());

                        return AlertDialog(
                          title: Text('Ajustar Descanso'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: minutosController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: 'Minutos'),
                              ),
                              TextField(
                                controller: segundosController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: 'Segundos'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                int nuevosMinutos =
                                    int.parse(minutosController.text);
                                int nuevosSegundos =
                                    int.parse(segundosController.text);
                                int nuevoTiempo =
                                    (nuevosMinutos * 60) + nuevosSegundos;
                                setState(() {
                                  widget.tiempo = nuevoTiempo;
                                });
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: Text('Guardar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descanso:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(widget.tiempo ~/ 60)}:${(widget.tiempo % 60).toString().padLeft(2, '0')} minutos',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _agregarSerie();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Agregar Serie',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}