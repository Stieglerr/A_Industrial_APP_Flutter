// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'database_helper.dart' as db;
import 'novo_anotacoes.dart';
import 'editar_anotacao.dart';

class Anotacoes extends StatefulWidget {
  const Anotacoes({super.key});

  @override
  AnotacoesState createState() => AnotacoesState();
}

class AnotacoesState extends State<Anotacoes> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
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
    if (!mounted) return;
    setState(() {
      _anotacoesFuture = _dbHelper.getAnotacoes();
    });
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

  Future<void> _excluirAnotacao(int id) async {
    await _vibrar();

    if (!mounted) return;
    final currentContext = context;

    final confirmar = await showDialog<bool>(
      context: currentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Deseja realmente excluir esta anotação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    await _dbHelper.deleteAnotacao(id);
    if (mounted) {
      await _carregarAnotacoes();
    }
  }

  Future<void> _editarAnotacao(Map<String, dynamic> anotacao) async {
    await _vibrar();

    if (!mounted) return;
    final currentContext = context;

    final result = await Navigator.push(
      currentContext,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                EditarAnotacaoScreen(anotacao: anotacao),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );

    if (!mounted || result != true) return;
    await _carregarAnotacoes();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarAnotacoes,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: RefreshIndicator(
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
                padding: const EdgeInsets.all(16),
                itemCount: anotacoes.length,
                itemBuilder: (context, index) {
                  final anotacao = anotacoes[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        anotacao['titulo'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Data: ${_formatarData(anotacao['data'])}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: corChumbo),
                            onPressed: () => _editarAnotacao(anotacao),
                            tooltip: 'Editar anotação',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _excluirAnotacao(anotacao['id']),
                            tooltip: 'Excluir anotação',
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
                                'Conteúdo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  anotacao['conteudo'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: corChumbo,
        onPressed: () async {
          await _vibrar();

          if (!mounted) return;
          final currentContext = context;

          final result = await Navigator.push(
            currentContext,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const NovaAnotacaoScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          );

          if (!mounted || result != true) return;
          await _carregarAnotacoes();
        },
        tooltip: 'Nova anotação',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
