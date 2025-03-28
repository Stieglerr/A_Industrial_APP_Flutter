import 'package:flutter/material.dart';
import 'dart:math';

class CalculadoraContactora extends StatefulWidget {
  const CalculadoraContactora({super.key});

  @override
  _CalculadoraContactoraState createState() => _CalculadoraContactoraState();
}

class _CalculadoraContactoraState extends State<CalculadoraContactora> {
  final List<int> _contatoras = [9, 12, 18, 25, 32, 40, 50, 65, 80, 95];
  final List<String> _relesTermicos = [
    '1.6-12',
    '5-18',
    '7-25',
    '10-32',
    '15-40',
    '20-50',
    '25-65',
    '30-80',
    '40-95',
  ];

  String _tipoMotor = 'monofasico';
  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _rendimentoController = TextEditingController(
    text: '0.85',
  );
  final TextEditingController _fpController = TextEditingController(
    text: '0.85',
  );
  final TextEditingController _tensaoController = TextEditingController();

  List<String> _contatorasSelecionadas = [];
  List<String> _relesSelecionados = [];
  double _amperagemCalculada = 0;

  void _calcularComponentes() {
    final cv = double.tryParse(_cvController.text);
    final tensao = double.tryParse(_tensaoController.text);

    final rendimento =
        _rendimentoController.text.isEmpty
            ? 0.85
            : double.tryParse(_rendimentoController.text) ?? 0.85;

    final fp =
        _fpController.text.isEmpty
            ? 0.85
            : double.tryParse(_fpController.text) ?? 0.85;

    if (cv == null || tensao == null || cv <= 0 || tensao <= 0) return;

    final potenciaW = cv * 735.5;
    double amperagem;

    if (_tipoMotor == 'monofasico') {
      amperagem = potenciaW / (tensao * rendimento * fp);
    } else {
      amperagem = potenciaW / (sqrt(3) * tensao * rendimento * fp);
    }

    _contatorasSelecionadas =
        _contatoras
            .where((a) => a >= amperagem * 1.25)
            .map((a) => 'C${a}A')
            .toList();

    _relesSelecionados =
        _relesTermicos.where((rele) {
          final faixa = rele.split('-');
          final min = double.parse(faixa[0]);
          final max = double.parse(faixa[1]);
          return amperagem >= min && amperagem <= max;
        }).toList();

    setState(() {
      _amperagemCalculada = amperagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dimensionamento de Componentes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Monofásico'),
                    value: 'monofasico',
                    groupValue: _tipoMotor,
                    onChanged:
                        (value) => setState(() {
                          _tipoMotor = value!;
                          _calcularComponentes();
                        }),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Trifásico'),
                    value: 'trifasico',
                    groupValue: _tipoMotor,
                    onChanged:
                        (value) => setState(() {
                          _tipoMotor = value!;
                          _calcularComponentes();
                        }),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _cvController,
              decoration: InputDecoration(
                labelText: 'Potência (CV)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 2.5',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calcularComponentes(),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _tensaoController,
              decoration: InputDecoration(
                labelText: 'Tensão (V)',
                border: OutlineInputBorder(),
                hintText: _tipoMotor == 'monofasico' ? 'Ex: 220' : 'Ex: 220',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calcularComponentes(),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rendimentoController,
                    decoration: InputDecoration(
                      labelText: 'Rendimento (η)',
                      border: OutlineInputBorder(),
                      hintText: '0.85',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _calcularComponentes(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fpController,
                    decoration: InputDecoration(
                      labelText: 'Fator de Potência',
                      border: OutlineInputBorder(),
                      hintText: '0.85',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _calcularComponentes(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              'Amperagem Calculada: ${_amperagemCalculada.toStringAsFixed(2)}A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCardComponentes(
                    'Contatoras Adequadas',
                    _contatorasSelecionadas,
                    Icons.power_settings_new,
                    Colors.orange,
                  ),
                  _buildCardComponentes(
                    'Relés Térmicos Compatíveis',
                    _relesSelecionados,
                    Icons.thermostat_auto,
                    Colors.green,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Valores utilizados:\n'
                'Rendimento: ${_rendimentoController.text.isEmpty ? '0.85 (padrão)' : _rendimentoController.text}\n'
                'Fator de Potência: ${_fpController.text.isEmpty ? '0.85 (padrão)' : _fpController.text}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardComponentes(
    String titulo,
    List<String> itens,
    IconData icone,
    Color cor,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                SizedBox(width: 10),
                Text(
                  titulo,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  itens
                      .map(
                        (item) => Chip(
                          label: Text(item),
                          backgroundColor: cor.withOpacity(0.1),
                          labelStyle: TextStyle(color: cor),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
