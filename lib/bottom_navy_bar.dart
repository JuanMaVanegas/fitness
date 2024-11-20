import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Widgets/DahsBoard.dart';
import 'package:fitness/Ejercicios/ejercicios.dart';
import 'package:fitness/home.dart';
import 'package:fitness/Recetas/recetas.dart';
import 'package:fitness/Perfil/profile.dart';
import 'package:fitness/Rutinas/rutinas.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  List<Widget> tabs = [
    Home(),
    Dahsboard(),
    Ejercicios(),
    DetRutinas(),
    Recetas(),
  ];
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

  int currentPage = 0;

  setPage(index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Fitness App",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: userProfile != null &&
                        userProfile!['Avatar'] != null
                    ? NetworkImage(userProfile!['Avatar'])
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
            )
          ],
        ),
        automaticallyImplyLeading:
            false, 
        elevation: 0.0,
      ),
      body: tabs[currentPage],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  size: 30,
                  color: currentPage == 0 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setPage(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.hourglass_empty,
                  size: 30,
                  color: currentPage == 1 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setPage(1),
              ),
              IconButton(
                icon: Icon(
                  Icons.fitness_center,
                  size: 30,
                  color: currentPage == 2 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setPage(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.directions_run,
                  size: 30,
                  color: currentPage == 3 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setPage(3),
              ),
              IconButton(
                icon: Icon(
                  Icons.restaurant,
                  size: 30,
                  color: currentPage == 4 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setPage(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
