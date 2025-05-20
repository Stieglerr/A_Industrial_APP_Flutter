import 'package:flutter/material.dart';

class ConsumoReais extends StatefulWidget {
  const ConsumoReais({super.key});

  @override
  ConsumoReaisState createState() => ConsumoReaisState();
}

class ConsumoReaisState extends State<ConsumoReais> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  String _watts = '';
  String _horas = '';
  String _precoKwh = '0.630';

  String _calcularConsumo() {
    final watts = double.tryParse(_watts);
    final horas = double.tryParse(_horas);
    final precoKwh = double.tryParse(_precoKwh);

    if (watts == null || horas == null || precoKwh == null) {
      return 'Insira valores numéricos válidos';
    }

    if (watts <= 0 || horas <= 0 || precoKwh <= 0) {
      return 'Valores devem ser maiores que zero';
    }

    final kWh = (watts * horas) / 1000;
    final custo = kWh * precoKwh;

    return 'Consumo: ${kWh.toStringAsFixed(2)} kWh\nCusto: R\$${custo.toStringAsFixed(2)}';
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
                labelText: 'Tempo de uso em horas',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _horas = value),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Preço do kWh',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _precoKwh = value),
              controller: TextEditingController(text: _precoKwh),
            ),
            const SizedBox(height: 30),
            Text(
              _calcularConsumo(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              '* Valor padrão válido para o Paraná (Dez/2024)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
