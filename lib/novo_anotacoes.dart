import 'package:flutter/material.dart';
import 'database_helper.dart' as db;

class NovaAnotacaoScreen extends StatefulWidget {
  const NovaAnotacaoScreen({Key? key}) : super(key: key);

  @override
  _NovaAnotacaoScreenState createState() => _NovaAnotacaoScreenState();
}

class _NovaAnotacaoScreenState extends State<NovaAnotacaoScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  final db.DatabaseHelper _dbHelper = db.DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Anotação'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _conteudoController,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.insertAnotacao({
                  'titulo': _tituloController.text,
                  'conteudo': _conteudoController.text,
                });
                Navigator.pop(context, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
