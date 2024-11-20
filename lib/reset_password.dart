import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/login_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Correo enviado'),
            content: Text(
              'Se ha enviado un correo electrónico para restablecer la contraseña. Por favor, revisa tu bandeja de entrada.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'No se pudo enviar el correo electrónico para restablecer la contraseña. Por favor, inténtalo de nuevo.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 50), 
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reestablecer contraseña',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Por favor, introduce tu dirección de correo electrónico',
                style: TextStyle(
                  color: Color(0xFF59706F),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Color(0xFF979797)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1B383A)),
                  ),
                ),
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: () => _resetPassword(context),
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color.fromARGB(255, 25, 28, 70),
                  ),
                  child: Text(
                    'Reestablecer contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
