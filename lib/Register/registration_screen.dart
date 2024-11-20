import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import '../login_screen.dart';
import '../Register/firebase_service.dart';
import '../Register/user_model.dart';
import '../Register/validator.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _fechanController = TextEditingController();
  bool isChecked = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _register() async {
    if (!isChecked) {
      // Mostrar un mensaje de error si el checkbox no está marcado
      await _showDialog(
        context,
        'Error',
        'Debes aceptar los términos y condiciones para registrarte.',
        isSuccess: false,
      );
      return; // Salir del método si no se aceptaron los términos
    }

    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await _firebaseService.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          UserModel userModel = UserModel(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            birthDate: _fechanController.text.trim(),
          );
          await _firebaseService.saveUserData(userCredential, userModel);

          await _showDialog(
            context,
            'Registro exitoso',
            'Tu cuenta ha sido registrada exitosamente.',
            isSuccess: true,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Ocurrió un error al registrarse';
        if (e.code == 'weak-password') {
          message = 'La contraseña es demasiado débil.';
        } else if (e.code == 'email-already-in-use') {
          message = 'El email ya está en uso por otra cuenta.';
        }
        await _showDialog(
          context,
          'Error',
          message,
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _showDialog(BuildContext context, String title, String message,
      {required bool isSuccess}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message,
              style: TextStyle(
                color: Colors.black,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar',
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                  )),
            ),
          ],
          backgroundColor: isSuccess ? Colors.white : Colors.white,
          titleTextStyle: TextStyle(
            color: isSuccess ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/register.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 70,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                          duration: Duration(seconds: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-1.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 100,
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-2.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 180,
                        height: 240,
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: Container(
                            child: Center(
                              child: Text(
                                "Registro",
                                style: GoogleFonts.caveat(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shadows: [
                                    Shadow(
                                      color: const Color.fromARGB(
                                          255, 112, 183, 241),
                                      blurRadius: 10,
                                      offset: Offset(3, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        controller: _nameController,
                        validator: Validator.validateName,
                        labelText: "Nombre",
                        hintText: "User",
                        icon: Iconsax.user,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        validator: Validator.validateEmail,
                        labelText: "Correo Electrónico",
                        hintText: "user@email.com",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        validator: Validator.validatePassword,
                        labelText: "Contraseña",
                        hintText: "********",
                        icon: Iconsax.key,
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _confirmpasswordController,
                        validator: (value) => Validator.validateConfirmPassword(
                            value, _passwordController.text),
                        labelText: "Confirmar Contraseña",
                        hintText: "********",
                        icon: Iconsax.key,
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _fechanController,
                        validator: Validator.validateFechaNacimiento,
                        labelText: "Fecha de Nacimiento",
                        hintText: "YYYY-MM-DD",
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            _fechanController.text = formattedDate;
                          }
                        },
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'Acepto los ',
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Términos y Condiciones',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      FadeInUp(
                        duration: Duration(milliseconds: 1900),
                        child: GestureDetector(
                          onTap: _register,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue,
                                  Colors.blue.withOpacity(0.6)
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Registrarse",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          'Ya tengo una cuenta',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String labelText;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  CustomTextField({
    required this.controller,
    required this.validator,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: 800),
      duration: Duration(milliseconds: 1500),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          labelStyle: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, color: Colors.white, size: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
