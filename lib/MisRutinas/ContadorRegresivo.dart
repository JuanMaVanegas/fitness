import 'dart:async';

import 'package:flutter/material.dart';

class ContadorRegresivoPage extends StatefulWidget {
  final int tiempo;
  final VoidCallback onCountdownFinished;

  ContadorRegresivoPage({required this.tiempo, required this.onCountdownFinished});

  @override
  _ContadorRegresivoPageState createState() => _ContadorRegresivoPageState();
}

class _ContadorRegresivoPageState extends State<ContadorRegresivoPage> {
  int minutosRestantes = 0;
  int segundosRestantes = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Inicializamos los minutos y segundos restantes basados en el tiempo total en segundos
    minutosRestantes = widget.tiempo ~/ 60; // Obtenemos los minutos
    segundosRestantes = widget.tiempo % 60; // Obtenemos los segundos restantes
    iniciarContador();
  }

  @override
  void dispose() {
    _timer.cancel(); // Asegúrate de detener el temporizador cuando el widget se desmonte
    super.dispose();
  }

  void iniciarContador() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (segundosRestantes > 0) {
        setState(() {
          segundosRestantes--;
        });
      } else {
        if (minutosRestantes > 0) {
          setState(() {
            minutosRestantes--;
            segundosRestantes = 59;
          });
        } else {
          widget.onCountdownFinished();
          timer.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutosRestantes:${segundosRestantes.toString().padLeft(2, '0')}', // Formateamos los segundos para que siempre tengan dos dígitos
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 20), // Separación entre los botones y el contador

            // Fila para los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (segundosRestantes < 50) {
                        segundosRestantes += 10;
                      } else {
                        minutosRestantes++;
                        segundosRestantes = (segundosRestantes + 10) % 60;
                      }
                    });
                  },
                  child: Text('+10s'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.onCountdownFinished();
                  },
                  child: Text('Terminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}