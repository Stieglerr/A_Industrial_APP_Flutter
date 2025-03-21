import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'novo_anotacoes.dart';

class Anotacoes extends StatefulWidget {
  const Anotacoes({Key? key}) : super(key: key);

  @override
  _AnotacoesState createState() => _AnotacoesState();
}

class _AnotacoesState extends State<Anotacoes> {
  final db.DatabaseHelper _dbHelper = db.DatabaseHelper();
  Future<List<Map<String, dynamic>>>? _anotacoesFuture;

  String _formatarData(String data) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(data));
    } catch (e) {
      return 'Data inválida';
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarAnotacoes();
  }

  Future<void> _carregarAnotacoes() async {
    setState(() {
      _anotacoesFuture = _dbHelper.getAnotacoes();
    });
  }

  Future<void> _excluirAnotacao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja realmente excluir esta anotação?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await _dbHelper.deleteAnotacao(id);
      await _carregarAnotacoes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarAnotacoes,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarAnotacoes,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _anotacoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar dados: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma anotação cadastrada'));
            }

            final anotacoes = snapshot.data!;

            return ListView.builder(
              itemCount: anotacoes.length,
              itemBuilder: (context, index) {
                final anotacao = anotacoes[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      anotacao['titulo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Data: ${_formatarData(anotacao['data'])}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async => _excluirAnotacao(anotacao['id']),
                      tooltip: 'Excluir anotação',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const Text(
                              'Conteúdo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                anotacao['conteudo'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NovaAnotacaoScreen()),
          );
          if (result == true) await _carregarAnotacoes();
        },
        child: const Icon(Icons.add),
        tooltip: 'Nova anotação',
      ),
    );
  }
}
