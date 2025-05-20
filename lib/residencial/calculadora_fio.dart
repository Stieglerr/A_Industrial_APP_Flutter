import 'package:flutter/material.dart';

class CalculadoraFio extends StatefulWidget {
  const CalculadoraFio({super.key});

  @override
  CalculadoraFioState createState() => CalculadoraFioState();
}

class CalculadoraFioState extends State<CalculadoraFio> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  final List<Map<String, dynamic>> _fios = [
    {'bitola': 2.5, 'amperagem': 21},
    {'bitola': 4.0, 'amperagem': 28},
    {'bitola': 6.0, 'amperagem': 36},
    {'bitola': 10.0, 'amperagem': 50},
    {'bitola': 16.0, 'amperagem': 68},
    {'bitola': 25.0, 'amperagem': 89},
    {'bitola': 35.0, 'amperagem': 112},
    {'bitola': 50.0, 'amperagem': 134},
    {'bitola': 70.0, 'amperagem': 171},
    {'bitola': 95.0, 'amperagem': 207},
    {'bitola': 120.0, 'amperagem': 237},
    {'bitola': 150.0, 'amperagem': 272},
    {'bitola': 185.0, 'amperagem': 309},
    {'bitola': 195.0, 'amperagem': 322},
  ];

  String _input = '';
  String _resultado = '';

  void _calcularEmTempoReal(String value) {
    setState(() {
      _input = value;
      final amperagem = double.tryParse(_input);

      if (amperagem == null || amperagem <= 0) {
        _resultado =
            _input.isEmpty ? 'Digite a amperagem' : 'Amperagem inválida!';
        return;
      }

      for (var fio in _fios) {
        if (amperagem <= fio['amperagem']) {
          _resultado =
              '${fio['bitola'].toStringAsFixed(1)} mm²\n'
              '(Suporta até ${fio['amperagem']}A)';
          return;
        }
      }

      _resultado = 'Necessário cabo especial\nacima de 195 mm²';
    });
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
                labelText: 'Amperagem (A)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.electrical_services,
                  color: Colors.black,
                ),
                hintText: 'Ex: 25.5',
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: _calcularEmTempoReal,
            ),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _resultado,
                key: ValueKey(_resultado),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      _resultado.contains('mm²')
                          ? Colors.green[800]
                          : Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'NBR 5410 - Capacidade de condução de corrente para '
                'condutores isolados em PVC, em eletrodutos embutidos '
                'em alvenaria à temperatura ambiente de 30°C',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
