import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'novo_orcamento.dart';
import 'editar_orcamento.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

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
    final confirmacao = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza que deseja excluir este orçamento?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    // Executar exclusão se confirmado
    if (confirmacao == true) {
      try {
        await _dbHelper.deleteOrcamento(id);
        await _carregarOrcamentos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orçamento excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir orçamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _gerarPDF(Map<String, dynamic> orcamento) async {
    final pdf = pw.Document();
    final produtos = orcamento['produtos'] as List<Map<String, dynamic>>;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Orçamento para ${orcamento['cliente']}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Paragraph(
                text:
                    'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(orcamento['data']))}',
              ),
              pw.Table.fromTextArray(
                context: context,
                headers: [
                  'Descrição',
                  'Quantidade',
                  'Valor Unitário',
                  'Valor Total',
                ],
                data:
                    produtos.map((produto) {
                      final double precoUnitario = produto['preco'] ?? 0.0;
                      final int quantidade = produto['quantidade'] ?? 1;
                      final double precoTotal = precoUnitario * quantidade;

                      return [
                        produto['nome'],
                        quantidade.toString(),
                        NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(precoUnitario),
                        NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(precoTotal),
                      ];
                    }).toList(),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (orcamento['desconto'] != null &&
                          orcamento['desconto'] > 0)
                        pw.Text(
                          'Subtotal: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['valor_total'] + orcamento['desconto'])}',
                        ),
                      if (orcamento['desconto'] != null &&
                          orcamento['desconto'] > 0)
                        pw.Text(
                          'Desconto: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['desconto'])}',
                        ),
                      pw.Text(
                        'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['valor_total'])}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/orcamento_${orcamento['id']}.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
    await Share.shareXFiles([XFile(file.path)]);
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
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditarOrcamentoScreen(
                                      orcamentoId: orcamento['id'],
                                    ),
                              ),
                            );

                            if (result == true) {
                              await _carregarOrcamentos();
                            }
                          },
                          tooltip: 'Editar orçamento',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.purple,
                          ),
                          onPressed: () async {
                            await _gerarPDF(orcamento);
                          },
                          tooltip: 'Gerar PDF',
                        ),
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
                                    'Qtde',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
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
                              final double precoUnitario =
                                  produto['preco'] ?? 0.0;
                              final int quantidade = produto['quantidade'] ?? 1;
                              final double precoTotal =
                                  precoUnitario * quantidade;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(produto['nome']),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        quantidade.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        NumberFormat.currency(
                                          locale: 'pt_BR',
                                          symbol: 'R\$',
                                        ).format(precoTotal),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (orcamento['desconto'] != null &&
                                        orcamento['desconto'] > 0) ...[
                                      Text(
                                        'Subtotal: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['valor_total'] + orcamento['desconto'])}',
                                      ),
                                      Text(
                                        'Desconto: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(orcamento['desconto'])}',
                                      ),
                                      const SizedBox(height: 4),
                                    ],
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
