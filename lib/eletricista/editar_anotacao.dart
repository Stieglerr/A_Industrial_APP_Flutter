import 'package:flutter/material.dart';
import 'database_helper.dart' as db;

class EditarAnotacaoScreen extends StatefulWidget {
  final Map<String, dynamic> anotacao;

  const EditarAnotacaoScreen({super.key, required this.anotacao});

  @override
  EditarAnotacaoScreenState createState() => EditarAnotacaoScreenState();
}

class EditarAnotacaoScreenState extends State<EditarAnotacaoScreen> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  final db.DatabaseHelper _dbHelper = db.DatabaseHelper();
  late TextEditingController _tituloController;
  late TextEditingController _conteudoController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.anotacao['titulo']);
    _conteudoController = TextEditingController(
      text: widget.anotacao['conteudo'],
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      final anotacaoAtualizada = {
        'id': widget.anotacao['id'],
        'titulo': _tituloController.text.trim(),
        'conteudo': _conteudoController.text.trim(),
      };

      try {
        await _dbHelper.updateAnotacao(anotacaoAtualizada);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar anotação: $e')),
          );
        }
      }
    }
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conteudoController,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o conteúdo da anotação';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarEdicao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
