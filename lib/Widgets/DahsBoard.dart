import 'package:fitness/Widgets/DataPicker.dart';
import 'package:flutter/material.dart';
import 'package:fitness/Widgets/IMC-calculator.dart';

class Dahsboard extends StatefulWidget {
  const Dahsboard({super.key});

  @override
  State<Dahsboard> createState() => _DahsboardState();
}

class _DahsboardState extends State<Dahsboard> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ocultar el banner de debug
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 400,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: CalendarScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        'Indice de masa corporal',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 400,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: BMICalculator(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
