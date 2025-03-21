import 'package:flutter/material.dart';
import 'database_helper.dart';

class RelatorioScreen extends StatefulWidget {
  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Orçamentos'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getOrcamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          }

          final orcamentos = snapshot.data!;

          return ListView.builder(
            itemCount: orcamentos.length,
            itemBuilder: (context, index) {
              final orcamento = orcamentos[index];
              return ExpansionTile(
                title: Text(orcamento['cliente']),
                subtitle: Text(
                  'Total: R\$${orcamento['valor_total'].toStringAsFixed(2)}',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children:
                          (orcamento['produtos'] as List).map<Widget>((
                            produto,
                          ) {
                            return ListTile(
                              title: Text(produto['descricao']),
                              trailing: Text(
                                'R\$${produto['valor'].toStringAsFixed(2)}',
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
