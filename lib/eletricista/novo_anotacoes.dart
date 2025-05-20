import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'database_helper.dart' as db;

class NovaAnotacaoScreen extends StatefulWidget {
  const NovaAnotacaoScreen({super.key});

  @override
  NovaAnotacaoScreenState createState() => NovaAnotacaoScreenState();
}

class NovaAnotacaoScreenState extends State<NovaAnotacaoScreen> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  final db.DatabaseHelper _dbHelper = db.DatabaseHelper();

  Future<void> _vibrar() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Erro na vibração: $e');
    }
  }

  Future<void> _salvarAnotacao() async {
    await _vibrar();

    if (_tituloController.text.isEmpty || _conteudoController.text.isEmpty) {
      return;
    }

    try {
      await _dbHelper.insertAnotacao({
        'titulo': _tituloController.text,
        'conteudo': _conteudoController.text,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar anotação: $e')));
      }
    }
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
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Digite o título da anotação',
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _conteudoController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Escreva sua anotação aqui...',
                    alignLabelWithHint: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarAnotacao,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Salvar Anotação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
