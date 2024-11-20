import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/Perfil/editarperfil.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            userProfile = userDoc.data() as Map<String, dynamic>?;
          });
          FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userId)
              .snapshots()
              .listen((DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              setState(() {
                userProfile = snapshot.data() as Map<String, dynamic>?;
              });
            }
          });
        } else {
          print('El documento del usuario no existe');
        }
      } catch (e) {
        print('Error al obtener los datos del usuario: $e');
      }
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          userProfile: userProfile,
          avatarImage: userProfile!['Avatar'] != null
              ? NetworkImage(userProfile!['Avatar'])
              : AssetImage('assets/default_avatar.png') as ImageProvider,
        ),
      ),
    );
  }

  String _getRoleText(int roleId) {
    return roleId == 1 ? 'Usuario' : 'Administrador';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print('Error al cerrar sesión: $e');
              }
            },
            icon: Icon(Icons.exit_to_app),
            label: Text('Cerrar sesión'),
          )
        ],
      ),
      body: Center(
        child: userProfile != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: userProfile!['Avatar'] != null
                        ? NetworkImage(userProfile!['Avatar'])
                        : AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  SizedBox(height: 50),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 20),
                      children: [
                        TextSpan(
                          text: 'Nombre: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${userProfile!['Nombre']}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 20),
                      children: [
                        TextSpan(
                          text: 'Email: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${userProfile!['Email']}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 20),
                      children: [
                        TextSpan(
                          text: 'Fecha de Nacimiento: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${userProfile!['Fecha_nacimiento']}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 20),
                      children: [
                        TextSpan(
                          text: 'Rol: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${_getRoleText(userProfile!['id_rol'])}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _editProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Color de fondo azul
                    ),
                    child: Text('Editar Información',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
