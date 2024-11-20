import 'package:flutter/material.dart';

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _imc = 0.0;
  String _status = '';
  double _AlturaCm = 0.0;
  double _peso = 0.0;

  void _calculateBMI() {
    setState(() {
      _AlturaCm = double.tryParse(_heightController.text) ?? 0;
      _peso = double.tryParse(_weightController.text) ?? 0;
      final double height =
          _AlturaCm / 100; // Convertimos la altura de cm a metros

      if (height > 0 && _peso > 0) {
        _imc = _peso / (height * height);
        if (_imc < 18.5) {
          _status = 'Bajo peso';
        } else if (_imc >= 18.5 && _imc < 24.9) {
          _status = 'Peso normal';
        } else if (_imc >= 25 && _imc < 29.9) {
          _status = 'Sobrepeso';
        } else {
          _status = 'Obesidad';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Altura (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Calcular IMC',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 24),
              if (_imc > 0)
                Column(
                  children: [
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _getStatusColor(), // Color del borde
                          width: 2.0, // Ancho del borde
                        ),
                        borderRadius:
                            BorderRadius.circular(10.0), // Borde circular
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8.0), // Borde circular
                        child: LinearProgressIndicator(
                          value:
                              _imc / 50, // Valor máximo de IMC típicamente 50
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_getStatusColor()),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 20,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (_status) {
      case 'Bajo peso':
        return LinearGradient(
          colors: [Colors.black, Colors.yellow[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Peso normal':
        return LinearGradient(
          colors: [Colors.black, Colors.green],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Sobrepeso':
        return LinearGradient(
          colors: [Colors.black, Colors.orange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Obesidad':
        return LinearGradient(
          colors: [Colors.black, Colors.red],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.black, Colors.black],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'Bajo peso':
        return Colors.yellow[700]!;
      case 'Peso normal':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      case 'Obesidad':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
