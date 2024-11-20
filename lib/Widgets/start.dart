import 'package:animate_do/animate_do.dart';
import 'package:fitness/login_screen.dart';
import 'package:fitness/Register/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class start extends StatefulWidget {
  const start({super.key});

  @override
  State<start> createState() => _startState();
}

class _startState extends State<start> {
  final List<Widget> imageTextList = [
    Image.asset(
      'assets/Ejercicio1.jpg',
    ),
    Image.asset('assets/Ejercicio2.jpg'),
    Image.asset('assets/Ejercicio3.jpg'),
    Image.asset('assets/Ejercicio4.jpg'),
  ];

  final List<String> textList = [
    'El único entrenamiento malo es el que no se hace.',
    'Tu cuerpo puede hacerlo, es tu mente la que debes convencer.',
    'El dolor que sientes hoy será la fuerza que necesitas mañana.',
    'No busques excusas, busca resultados.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CarouselSlider.builder(
                          itemCount: imageTextList.length,
                          options: CarouselOptions(
                            height: 600, // Altura del carrusel
                            enableInfiniteScroll:
                                true, // Desplazamiento infinito
                            autoPlay: true, // Reproducción automática
                            autoPlayInterval: Duration(
                                seconds: 4), // Intervalo entre las diapositivas
                            autoPlayAnimationDuration: Duration(
                                milliseconds:
                                    800), // Duración de la animación de reproducción automática
                            pauseAutoPlayOnTouch:
                                true, // Pausar reproducción automática al tocar
                            enlargeCenterPage:
                                true, // Agrandar la página central
                          ),
                          itemBuilder:
                              (BuildContext context, int index, int realIndex) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                imageTextList[index],
                                SizedBox(height: 40),
                                Text(
                                  textList[index],
                                  style: GoogleFonts.raleway(
                                      textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 70,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1900),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationScreen(),
                              ),
                            );
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Regístrate',
                                style: GoogleFonts.raleway(
                                    textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                )),
                              ))),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Ya tengo una cuenta',
                      style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
