import 'package:fitness/Rutinas/ListaRutinas.dart';
import 'package:fitness/MisRutinas/Misrutinas.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _userName;
  int _diasEntrenamiento = 0;
  DateTime? _ultimaActualizacion;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTrainingInfo();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _userName = userData['Nombre'];
        });
      }
    }
  }

  Future<void> _loadTrainingInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final progresoDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('progreso')
          .doc('entrenamientos')
          .get();

      if (progresoDoc.exists) {
        setState(() {
          _diasEntrenamiento = progresoDoc['dias_entrenamiento'] ?? 0;
          _ultimaActualizacion = progresoDoc['ultima_actualizacion'] != null
              ? (progresoDoc['ultima_actualizacion'] as Timestamp).toDate()
              : null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime fechaActual = DateTime.now();
    String fechaFormateada =
        '${fechaActual.day} de ${_getMes(fechaActual.month)}';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, ${_userName ?? 'Usuario'}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildTrainingInfoContainer(fechaFormateada),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Mis entrenamientos',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    FloatingActionButton(
                      heroTag: 'uniqueTag5',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListaRutinasPage(),
                          ),
                        );
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              _buildMisRutinasList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingInfoContainer(String fechaFormateada) {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrenamientos Realizados',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fechaFormateada,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                _diasEntrenamiento.toString(), // Corrección aquí
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          if (_ultimaActualizacion != null) 
            Text(
              'Última actualización: ${DateFormat.yMMMd().format(_ultimaActualizacion!)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  String _getMes(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  Widget _buildMisRutinasList() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text('Inicia sesión para ver tus rutinas'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('MisRutinas')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No hay rutinas disponibles.'),
          );
        }

        final List<DocumentSnapshot> rutinas = snapshot.data!.docs;
        final double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: rutinas.map((rutina) {
                final String nombre = rutina['nombre'];
                final String imagenUrl = rutina['imagen'];

                return Dismissible(
                  key: Key(rutina.id),
                  onDismissed: (direction) {
                    print('ID del documento a eliminar: ${rutina.id}');
                    FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user.uid)
                        .collection('MisRutinas')
                        .doc(rutina.id)
                        .delete()
                        .then((_) {
                      print('Rutina eliminada');
                    }).catchError((error) {
                      print('Error al eliminar la rutina: $error');
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MisRutinas(
                            rutinaId: rutina.id,
                            nombre: nombre,
                            imagenUrl: imagenUrl,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      width: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0)),
                            child: Container(
                              height:
                                  150.0, // Ajusta la altura según sea necesario
                              width: double.infinity,
                              child: Image.network(
                                imagenUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            nombre,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
