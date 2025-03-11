import 'package:flutter/material.dart';
import 'dart:math';

class CalculadoraAMotor extends StatefulWidget {
  @override
  _CalculadoraAMotorState createState() => _CalculadoraAMotorState();
}

class _CalculadoraAMotorState extends State<CalculadoraAMotor> {
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

  void _calcularAmperagem() {
    if (!_formKey.currentState!.validate()) return;

    final cv = double.tryParse(_cvController.text);
    final tensao = double.tryParse(_tensaoController.text);
    final fp = double.tryParse(_fpController.text);
    final rendimento = double.tryParse(_rendimentoController.text);

    if (cv == null || tensao == null || fp == null || rendimento == null)
      return;

    final potenciaW = cv * 735.5;

    double amperagem;
    if (_tipoMotor == 'monofasico') {
      amperagem = potenciaW / (tensao * rendimento * fp);
    } else {
      amperagem = potenciaW / (sqrt(3) * tensao * fp * rendimento);
    }

    setState(() {
      _resultado = 'Amperagem: ${amperagem.toStringAsFixed(2)} A';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora para Motores')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo de Motor:', style: TextStyle(fontSize: 16)),
                  RadioListTile<String>(
                    title: Text('Monofásico'),
                    value: 'monofasico',
                    groupValue: _tipoMotor,
                    onChanged:
                        (value) => setState(() {
                          _tipoMotor = value!;
                          _calcularAmperagem();
                        }),
                  ),
                  RadioListTile<String>(
                    title: Text('Trifásico'),
                    value: 'trifasico',
                    groupValue: _tipoMotor,
                    onChanged:
                        (value) => setState(() {
                          _tipoMotor = value!;
                          _calcularAmperagem();
                        }),
                  ),
                  TextFormField(
                    controller: _cvController,
                    decoration: InputDecoration(
                      labelText: 'Potência (CV)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Insira a potência';
                      if (double.tryParse(value) == null)
                        return 'Valor inválido';
                      return null;
                    },
                    onChanged: (_) => _calcularAmperagem(),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _tensaoController,
                    decoration: InputDecoration(
                      labelText: 'Tensão (V)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Insira a tensão';
                      if (double.tryParse(value) == null)
                        return 'Valor inválido';
                      return null;
                    },
                    onChanged: (_) => _calcularAmperagem(),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _fpController,
                    decoration: InputDecoration(
                      labelText: 'Fator de Potência (cos φ)',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 0.85',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Insira o fator de potência';
                      final fp = double.tryParse(value);
                      if (fp == null || fp <= 0 || fp > 1)
                        return 'Valor entre 0.1 e 1.0';
                      return null;
                    },
                    onChanged: (_) => _calcularAmperagem(),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _rendimentoController,
                    decoration: InputDecoration(
                      labelText: 'Rendimento (η)',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 0.88',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Insira o rendimento';
                      final rend = double.tryParse(value);
                      if (rend == null || rend <= 0 || rend > 1)
                        return 'Valor entre 0.1 e 1.0';
                      return null;
                    },
                    onChanged: (_) => _calcularAmperagem(),
                  ),
                  SizedBox(height: 30),
                  Text(
                    _resultado,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
