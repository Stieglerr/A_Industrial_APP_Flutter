import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

class CalculadoraFioMotor extends StatefulWidget {
  const CalculadoraFioMotor({super.key});

  @override
  _CalculadoraFioMotorState createState() => _CalculadoraFioMotorState();
}

class _CalculadoraFioMotorState extends State<CalculadoraFioMotor> {
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

  String _tipoMotor = 'monofasico';
  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _tensaoController = TextEditingController();
  final TextEditingController _rendimentoController = TextEditingController(
    text: '0.85',
  );
  final TextEditingController _fpController = TextEditingController(
    text: '0.85',
  );
  String _resultado = '';

  Future<void> _vibrar() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Erro na vibração: $e');
    }
  }

  void _calcularFiacao() {
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

    setState(() {
      if (cv == null || tensao == null || cv <= 0 || tensao <= 0) {
        _resultado =
            _cvController.text.isEmpty || _tensaoController.text.isEmpty
                ? 'Digite os valores necessários'
                : 'Valores inválidos!';
        return;
      }

      final potenciaW = cv * 735.5;
      double amperagem =
          _tipoMotor == 'monofasico'
              ? potenciaW / (tensao * rendimento * fp)
              : potenciaW / (sqrt(3) * tensao * rendimento * fp);

      for (var fio in _fios) {
        if (amperagem <= fio['amperagem']) {
          _resultado =
              '${fio['bitola'].toStringAsFixed(1)} mm²\n(Suporta até ${fio['amperagem']}A)';
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
                onChanged: (_) => _calcularFiacao(),
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
                onChanged: (_) => _calcularFiacao(),
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
                      onChanged: (_) => _calcularFiacao(),
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
                      onChanged: (_) => _calcularFiacao(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
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
          _calcularFiacao();
        });
      },
      selectedColor: corChumbo.withOpacity(0.2),
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
}
