import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

class CalculadoraAMotor extends StatefulWidget {
  const CalculadoraAMotor({super.key});

  @override
  CalculadoraAMotorState createState() => CalculadoraAMotorState();
}

class CalculadoraAMotorState extends State<CalculadoraAMotor> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  final _formKey = GlobalKey<FormState>();
  String _tipoMotor = 'monofasico';
  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _tensaoController = TextEditingController();
  final TextEditingController _fpController = TextEditingController(
    text: '0.85',
  );
  final TextEditingController _rendimentoController = TextEditingController(
    text: '0.88',
  );
  String _resultado = '';
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _tipoMotor = _prefs.getString('tipoMotor') ?? 'monofasico';
      _cvController.text = _prefs.getString('cv') ?? '';
      _tensaoController.text = _prefs.getString('tensao') ?? '';
      _fpController.text = _prefs.getString('fp') ?? '0.85';
      _rendimentoController.text = _prefs.getString('rendimento') ?? '0.88';
    });
    _calcularAmperagem();
  }

  Future<void> _vibrar() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Erro na vibração: $e');
    }
  }

  void _salvarConfiguracoes() {
    _prefs.setString('tipoMotor', _tipoMotor);
    _prefs.setString('cv', _cvController.text);
    _prefs.setString('tensao', _tensaoController.text);
    _prefs.setString('fp', _fpController.text);
    _prefs.setString('rendimento', _rendimentoController.text);
  }

  void _calcularAmperagem() {
    if (!_formKey.currentState!.validate()) return;

    final cv = double.tryParse(_cvController.text);
    final tensao = double.tryParse(_tensaoController.text);
    final fp = double.tryParse(_fpController.text);
    final rendimento = double.tryParse(_rendimentoController.text);

    if (cv == null || tensao == null || fp == null || rendimento == null) {
      return;
    }

    final potenciaW = cv * 735.5;

    double amperagem;
    if (_tipoMotor == 'monofasico') {
      amperagem = potenciaW / (tensao * rendimento * fp);
    } else {
      amperagem = potenciaW / (sqrt(3) * tensao * fp * rendimento);
    }

    setState(() {
      _resultado = '${amperagem.toStringAsFixed(2)} A';
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
          child: Form(
            key: _formKey,
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
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira a potência';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    _salvarConfiguracoes();
                    _calcularAmperagem();
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _tensaoController,
                  decoration: InputDecoration(
                    labelText: 'Tensão (V)',
                    border: const OutlineInputBorder(),
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText:
                        _tipoMotor == 'monofasico' ? 'Ex: 220' : 'Ex: 380',
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira a tensão';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    _salvarConfiguracoes();
                    _calcularAmperagem();
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _rendimentoController,
                        decoration: const InputDecoration(
                          labelText: 'Rendimento (η)',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: '0.88',
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira o rendimento';
                          }
                          final rend = double.tryParse(value);
                          if (rend == null || rend <= 0 || rend > 1) {
                            return 'Valor entre 0.1 e 1.0';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          _salvarConfiguracoes();
                          _calcularAmperagem();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira o fator de potência';
                          }
                          final fp = double.tryParse(value);
                          if (fp == null || fp <= 0 || fp > 1) {
                            return 'Valor entre 0.1 e 1.0';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          _salvarConfiguracoes();
                          _calcularAmperagem();
                        },
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _tipoMotor == 'monofasico'
                        ? 'Fórmula: A = (CV × 735.5) / (V × cosφ × η)'
                        : 'Fórmula: A = (CV × 735.5) / (√3 × V × cosφ × η)',
                    style: TextStyle(
                      fontSize: 14,
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
          _salvarConfiguracoes();
          _calcularAmperagem();
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
}
