import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

class CalculadoraContactora extends StatefulWidget {
  const CalculadoraContactora({super.key});

  @override
  CalculadoraContactoraState createState() => CalculadoraContactoraState();
}

class CalculadoraContactoraState extends State<CalculadoraContactora> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
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

  Future<void> _vibrar() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Erro na vibração: $e');
    }
  }

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
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logointpreto.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: corChumbo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMotorTypeButton('Monofásico', 'monofasico'),
                  const SizedBox(width: 20),
                  _buildMotorTypeButton('Trifásico', 'trifasico'),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _cvController,
                decoration: const InputDecoration(
                  labelText: 'Potência (CV)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Ex: 2.5',
                ),
                style: const TextStyle(color: Colors.black),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calcularComponentes(),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _tensaoController,
                decoration: InputDecoration(
                  labelText: 'Tensão (V)',
                  border: const OutlineInputBorder(),
                  labelStyle: const TextStyle(color: Colors.black),
                  hintText: _tipoMotor == 'monofasico' ? 'Ex: 220' : 'Ex: 380',
                ),
                style: const TextStyle(color: Colors.black),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calcularComponentes(),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rendimentoController,
                      decoration: const InputDecoration(
                        labelText: 'Rendimento (η)',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: '0.85',
                      ),
                      style: const TextStyle(color: Colors.black),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _calcularComponentes(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _fpController,
                      decoration: const InputDecoration(
                        labelText: 'Fator de Potência',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: '0.85',
                      ),
                      style: const TextStyle(color: Colors.black),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _calcularComponentes(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                'Amperagem Calculada: ${_amperagemCalculada.toStringAsFixed(2)}A',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 20),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotorTypeButton(String text, String value) {
    return ChoiceChip(
      label: Text(text),
      selected: _tipoMotor == value,
      onSelected: (selected) async {
        await _vibrar();
        setState(() {
          _tipoMotor = value;
          _calcularComponentes();
        });
      },
      selectedColor: corChumbo.withAlpha((0.2 * 255).toInt()),
      labelStyle: TextStyle(
        color: _tipoMotor == value ? corChumbo : Colors.grey[700],
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _tipoMotor == value ? corChumbo : Colors.grey[300]!,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (itens.isEmpty)
              const Text(
                'Nenhum componente encontrado',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    itens
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            backgroundColor: cor.withAlpha((0.1 * 255).toInt()),
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
