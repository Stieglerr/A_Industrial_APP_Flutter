import 'package:flutter/material.dart';

class CalculadoraAmperes extends StatefulWidget {
  const CalculadoraAmperes({super.key});

  @override
  CalculadoraAmperesState createState() => CalculadoraAmperesState();
}

class CalculadoraAmperesState extends State<CalculadoraAmperes> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
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
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/logointpreto.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        backgroundColor: corChumbo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Potência em Watts (W)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _watts = value),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tensão em Volts (V)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _volts = value),
            ),
            const SizedBox(height: 30),
            Text(
              _calculateAmperes(),
              style: const TextStyle(
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
