import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'novo_orcamento.dart';

class Orcamento extends StatefulWidget {
  @override
  _OrcamentoState createState() => _OrcamentoState();
}

class _OrcamentoState extends State<Orcamento> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Future<List<Map<String, dynamic>>>? _orcamentosFuture;

  @override
  void initState() {
    super.initState();
    _carregarOrcamentos();
  }

  Future<void> _carregarOrcamentos() async {
    setState(() {
      _orcamentosFuture = _dbHelper.getOrcamentos();
    });
  }

  Future<void> _excluirOrcamento(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja realmente excluir este orçamento?'),
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
      await _dbHelper.deleteOrcamento(id);
      await _carregarOrcamentos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _carregarOrcamentos();
            },
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarOrcamentos,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _orcamentosFuture,
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
              return const Center(child: Text('Nenhum orçamento cadastrado'));
            }

            final orcamentos = snapshot.data!;

            return ListView.builder(
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];
                final produtos =
                    orcamento['produtos'] as List<Map<String, dynamic>>;

                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      orcamento['cliente'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['valor_total'])}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(orcamento['data']))}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Itens: ${produtos.length}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _excluirOrcamento(orcamento['id']);
                          },
                          tooltip: 'Excluir orçamento',
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const Text(
                              'Produtos/Serviços',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Descrição',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Valor',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 10),
                            ...produtos.map((produto) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(produto['descricao']),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        NumberFormat.currency(
                                          locale: 'pt_BR',
                                          symbol: 'R\$',
                                        ).format(produto['valor']),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['valor_total'])}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.purple[800],
                                  ),
                                ),
                              ],
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
            MaterialPageRoute(builder: (context) => NovoOrcamentoScreen()),
          );
          if (result == true) {
            await _carregarOrcamentos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
