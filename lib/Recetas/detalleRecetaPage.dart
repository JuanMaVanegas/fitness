import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleRecetaPage extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  DetalleRecetaPage(this.documentSnapshot);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Receta'),
      ),
      body: Stack(
        children: [
          // Fondo con la imagen
          Positioned.fill(
            child: documentSnapshot['imagen'] != null
                ? Image.network(
                    documentSnapshot['imagen'].toString(),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/balanced.jpg',
                    fit: BoxFit.cover,
                  ),
          ),
          // Contenedor con otros datos encima
          // Contenedor con otros datos encima
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              color:
                  Colors.black.withOpacity(0.5), // Color de fondo transparente
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentSnapshot['nombre'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      // Duración
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Duración',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${documentSnapshot['duracion']} minutos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Porciones
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Porciones',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${documentSnapshot['porciones']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Calorías
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Calorías',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${documentSnapshot['calorias']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Separación entre las secciones

                  // Descripción
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    documentSnapshot['descripcion'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20), // Separación entre las secciones

                  // Ingredientes
                  Text(
                    'Ingredientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      documentSnapshot['ingredientes'].length,
                      (index) => Text(
                        '- ${documentSnapshot['ingredientes'][index]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Pasos a seguir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      documentSnapshot['pasos'].length,
                      (index) => Text(
                        '${index + 1}. ${documentSnapshot['pasos'][index]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
