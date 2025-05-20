import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculadoraEletroduto extends StatefulWidget {
  const CalculadoraEletroduto({super.key});

  @override
  CalculadoraEletrodutoState createState() => CalculadoraEletrodutoState();
}

class CalculadoraEletrodutoState extends State<CalculadoraEletroduto> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);

  // Cabos corrigidos e atualizados
  final Map<double, double> _cabos = {
    0.5: 1.4,
    1.5: 2.1,
    2.5: 3.1,
    4: 3.9,
    6: 4.8,
    10: 6.2,
    16: 7.5,
    25: 9.3,
    35: 10.8,
    50: 12.9,
    70: 15.3,
    95: 17.9,
    120: 20.2,
    150: 22.7,
    185: 25.4,
    240: 28.7,
  };

  final Map<String, double> _eletrodutos = {
    '3/8"': 12.7,
    '1/2"': 16.1,
    '3/4"': 21.1,
    '1"': 26.6,
    '1 1/4"': 35.1,
    '1 1/2"': 40.9,
    '2"': 52.5,
    '2 1/2"': 63.5,
    '3"': 78.1,
    '3 1/2"': 90.7,
    '4"': 103.5,
  };

  double _selectedCable = 2.5;
  String _quantity = '1';
  String _result = '';

  void _calculate() {
    final qty = int.tryParse(_quantity) ?? 0;
    if (qty < 1) {
      setState(() => _result = 'Quantidade inválida!');
      return;
    }

    final cableDiameter = _cabos[_selectedCable]!;
    final cableArea = _calculateArea(cableDiameter) * qty;
    final occupancyRate =
        qty == 1
            ? 0.53
            : qty == 2
            ? 0.31
            : 0.40;
    final requiredArea = cableArea / occupancyRate;

    String suitableConduit = 'Nenhum eletroduto adequado';
    _eletrodutos.forEach((name, diameter) {
      final area = _calculateArea(diameter);
      if (area >= requiredArea &&
          suitableConduit == 'Nenhum eletroduto adequado') {
        suitableConduit = '$name (${diameter}mm)';
      }
    });

    setState(() => _result = 'Eletroduto necessário:\n$suitableConduit');
  }

  double _calculateArea(double diameter) {
    final radius = diameter / 2;
    return math.pi * math.pow(radius, 2);
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
            DropdownButton<double>(
              value: _selectedCable,
              items:
                  _cabos.keys.map((cable) {
                    return DropdownMenuItem<double>(
                      value: cable,
                      child: Text(
                        '${cable.toStringAsFixed(cable.truncateToDouble() == cable ? 0 : 1)} mm² (∅${_cabos[cable]}mm)',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCable = value!;
                  _calculate();
                });
              },
              isExpanded: true,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Quantidade de cabos',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _quantity = value;
                  _calculate();
                });
              },
            ),
            const SizedBox(height: 30),
            Text(
              _result,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'De acordo com a NBR5410:\n'
              '1 cabo: 53% de ocupação\n'
              '2 cabos: 31% de ocupação\n'
              '3+ cabos: 40% de ocupação',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
