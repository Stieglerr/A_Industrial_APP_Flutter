import 'package:flutter/material.dart';
import 'database_helper.dart' as db;

class EditarAnotacaoScreen extends StatefulWidget {
  final Map<String, dynamic> anotacao;

  const EditarAnotacaoScreen({super.key, required this.anotacao});

  @override
  _EditarAnotacaoScreenState createState() => _EditarAnotacaoScreenState();
}

class _EditarAnotacaoScreenState extends State<EditarAnotacaoScreen> {
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
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar anotação: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Anotação'),
        backgroundColor: Colors.purple,
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
                ),
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
                ),
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
                  backgroundColor: Colors.purple,
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
