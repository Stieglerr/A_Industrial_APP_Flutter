import 'package:flutter/material.dart';

class ConverterWVA extends StatefulWidget {
  const ConverterWVA({super.key});

  @override
  _ConverterWVAState createState() => _ConverterWVAState();
}

class _ConverterWVAState extends State<ConverterWVA> {
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
      appBar: AppBar(title: Text('Converter W em VA')),
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
                labelText: 'Fator de Potência (0.1 a 1.0)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _powerFactor = value),
            ),
            SizedBox(height: 30),
            Text(
              _calculateVA(),
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
