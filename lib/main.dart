import 'package:fitness/internet_connection_wrapper.dart';
import 'package:fitness/Widgets/splahs.dart';
import 'package:fitness/Widgets/start.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("f58d8fee-0f8c-47ef-a177-ac3875568b99");
  OneSignal.Notifications.requestPermission(true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      initialRoute: "splash",
      routes: {
        '/login': (context) => LoginScreen(),
        "splash": (context) => const splashScreen(),
        "inicio": (context) => const start(),
      },
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.ralewayTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: InternetConnectionWrapper(
        child: LoginScreen(),
      ),
    );
  }
}
