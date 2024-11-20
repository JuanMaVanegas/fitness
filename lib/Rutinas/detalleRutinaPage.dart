import 'package:fitness/Rutinas/listaejercicios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RutinaDetailPage extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  RutinaDetailPage({required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    final String name = documentSnapshot['nombre'];
    final String imageUrl = documentSnapshot['imagen'];
    final String descripcion = documentSnapshot['descripcion'];
    final String rutinaId = documentSnapshot.id;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(height: 20),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            descripcion,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Ejercicios de la rutina:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
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
                                RutinaDayWidget(
                                  dayOfWeek: dayOfWeek,
                                  rutinaId: rutinaId,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RutinaDayWidget extends StatefulWidget {
  final String dayOfWeek;
  final String rutinaId;

  RutinaDayWidget({
    required this.dayOfWeek,
    required this.rutinaId,
  });

  @override
  _RutinaDayWidgetState createState() => _RutinaDayWidgetState();
}

class _RutinaDayWidgetState extends State<RutinaDayWidget> {
  int cantidadDocumentos = 0;

  @override
  void initState() {
    super.initState();
    obtenerCantidadDocumentos();
  }

  Future<void> obtenerCantidadDocumentos() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/Rutinas/${widget.rutinaId}/${widget.dayOfWeek}')
        .get();

    if (mounted) {
      // Verificar si el widget está montado
      setState(() {
        cantidadDocumentos = querySnapshot.docs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleEjercicio(
              titulo: widget.dayOfWeek,
              descripcion:
                  'Descripción detallada de los ejercicios para ${widget.dayOfWeek}',
              rutinaId: widget.rutinaId,
              cantidadDocumentos: cantidadDocumentos,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dayOfWeek,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              'Cantidad de documentos: $cantidadDocumentos',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
