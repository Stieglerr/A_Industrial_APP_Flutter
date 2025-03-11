import 'package:flutter/material.dart';

class CalculadoraAmperes extends StatefulWidget {
  @override
  _CalculadoraAmperesState createState() => _CalculadoraAmperesState();
}

class _CalculadoraAmperesState extends State<CalculadoraAmperes> {
  String _watts = '';
  String _volts = '';

  String _calculateAmperes() {
    final watts = double.tryParse(_watts);
    final volts = double.tryParse(_volts);

    if (watts == null || volts == null) {
      return 'Insira valores numéricos válidos';
    }

    if (volts <= 0) {
      return 'A voltagem deve ser maior que zero';
    }

    if (watts < 0) {
      return 'A potência não pode ser negativa';
    }

    final amperes = watts / volts;
    return 'Resultado: ${amperes.toStringAsFixed(2)} A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora Amperes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Potência em Watts (W)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _watts = value),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tensão em Volts (V)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _volts = value),
            ),
            SizedBox(height: 30),
            Text(
              _calculateAmperes(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
