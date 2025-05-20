import 'package:flutter/material.dart';

class ConverterWVA extends StatefulWidget {
  const ConverterWVA({super.key});

  @override
  ConverterWVAState createState() => ConverterWVAState();
}

class ConverterWVAState extends State<ConverterWVA> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  String _watts = '';
  String _powerFactor = '';

  String _calculateVA() {
    final watts = double.tryParse(_watts);
    final powerFactor = double.tryParse(_powerFactor);

    if (watts == null || powerFactor == null) {
      return 'Insira valores numéricos válidos';
    }

    if (powerFactor <= 0 || powerFactor > 1) {
      return 'Fator de potência deve estar entre 0 e 1';
    }

    if (powerFactor == 0) {
      return 'Fator de potência não pode ser zero';
    }

    final va = watts / powerFactor;
    return 'Resultado: ${va.toStringAsFixed(2)} VA';
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
                labelText: 'Fator de Potência (0.1 a 1.0)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _powerFactor = value),
            ),
            const SizedBox(height: 30),
            Text(
              _calculateVA(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
