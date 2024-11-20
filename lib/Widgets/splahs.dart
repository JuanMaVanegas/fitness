
import 'package:fitness/Widgets/start.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();
    var d =
        const Duration(seconds: 5); 
    Future.delayed(d, () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const start()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Text(
                        'Fitness',
                        style: GoogleFonts.caveat(
                          textStyle: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Text(
                        'Home',
                        style: GoogleFonts.caveat(
                          textStyle: TextStyle(
                              fontSize: 75,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: const Color.fromARGB(255, 112, 183, 241),
                                  blurRadius: 10,
                                  offset: Offset(3, 1),
                                )
                              ]),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 400,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 100),
                      child: Image.asset(
                        'assets/Caminando.gif',
                        width: 65,
                        height: 65,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        'Inicializando',
                        style: GoogleFonts.caveat(
                            textStyle:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
