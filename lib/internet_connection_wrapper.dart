import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class NoConnection extends StatelessWidget {
  const NoConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Image.asset('assets/no-connection.gif'),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "¡Ups! 😓",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "No se encontró conexión a Internet. Verifique su conexión o intente nuevamente.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 35),
                MaterialButton(
                  onPressed: () {},
                  height: 45,
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.orange.shade400,
                  child: Text(
                    "Reintentar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;

  const InternetConnectionWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  _InternetConnectionWrapperState createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState extends State<InternetConnectionWrapper> {
  bool _isConnected = false; 

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) { 
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return _isConnected ? widget.child : NoConnection();
        } catch (e) {
          print('Error en InternetConnectionWrapper: $e');
          return Scaffold(
            body: Center(
              child: Text('Error inesperado. Por favor, inténtelo de nuevo.'),
            ),
          );
        }
      },
    );
  }
}
