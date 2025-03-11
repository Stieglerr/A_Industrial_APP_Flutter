import 'package:flutter/material.dart';

class ConsumoReais extends StatefulWidget {
  @override
  _ConsumoReaisState createState() => _ConsumoReaisState();
}

class _ConsumoReaisState extends State<ConsumoReais> {
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
      appBar: AppBar(title: Text('Consumo R\$')),
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
                labelText: 'Tempo de uso em horas',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _horas = value),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Preço do kWh',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() => _precoKwh = value),
              controller: TextEditingController(text: _precoKwh),
            ),
            SizedBox(height: 30),
            Text(
              _calcularConsumo(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              '* Valor padrão válido para o Paraná (Dez/2024)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
