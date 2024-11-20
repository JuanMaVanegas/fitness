import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness/bottom_navy_bar.dart';
import 'package:fitness/reset_password.dart';
import 'package:fitness/Register/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Declaracion de variables
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _rememberMe = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = _prefs?.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = _prefs?.getString('email') ?? '';
        _passwordController.text = _prefs?.getString('password') ?? '';
      }
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          if (_rememberMe) {
            _prefs?.setBool('rememberMe', true);
            _prefs?.setString('email', _emailController.text.trim());
            _prefs?.setString('password', _passwordController.text.trim());
          } else {
            _prefs?.remove('rememberMe');
            _prefs?.remove('email');
            _prefs?.remove('password');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CustomBottomNavigationBar()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No se encontró un usuario con este correo electrónico.';
            break;
          case 'wrong-password':
            errorMessage = 'La contraseña es incorrecta.';
            break;
          default:
            errorMessage = 'Error desconocido: ${e.message}';
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        _showErrorDialog('Error inesperado: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey),
          ),
          elevation: 5.0,
          title: Text(
            "Error de inicio de sesión",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.blue,
                ),
                foregroundColor: MaterialStateProperty.all(
                  Colors.white,
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Text("Aceptar"),
            ),
          ],
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
                      image: AssetImage('assets/images/login_4.png'),
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
                        left: 140,
                        height: 240,
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: Container(
                            child: Center(
                              child: Text(
                                "Iniciar sesión",
                                style: GoogleFonts.caveat(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: const Color.fromARGB(
                                              255, 112, 183, 241),
                                          blurRadius: 10,
                                          offset: Offset(3, 1),
                                        )
                                      ]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        label: 'Correo Electrónico',
                        icon: Iconsax.user,
                        isPassword: false,
                        controller: _emailController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingrese su correo electrónico'
                            : null,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        label: 'Contraseña',
                        icon: Iconsax.key,
                        isPassword: !_passwordVisible,
                        controller: _passwordController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingrese su contraseña'
                            : null,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        delay: Duration(milliseconds: 800),
                        duration: Duration(milliseconds: 1500),
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              checkColor: Colors.blue,
                              fillColor: MaterialStateProperty.resolveWith(
                                  (states) => Colors.white),
                            ),
                            Text(
                              'Recordar inicio de sesión',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 2000),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen()),
                            );
                          },
                          child: Text(
                            "Olvidé mi contraseña",
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 1900),
                        child: GestureDetector(
                          onTap: _login,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Colors.blue,
                                  Colors.blue.withOpacity(0.6),
                                ])),
                            child: Center(
                              child: Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 2000),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationScreen()),
                            );
                          },
                          child: Text(
                            "¿No tienes cuenta? Regístrate",
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                        ),
                      ),
                      SizedBox(height: 70),
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
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.label,
    required this.icon,
    required this.isPassword,
    required this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}