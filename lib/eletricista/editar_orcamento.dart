import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class EditarOrcamentoScreen extends StatefulWidget {
  final int orcamentoId;

  const EditarOrcamentoScreen({required this.orcamentoId, Key? key})
    : super(key: key);

  @override
  _EditarOrcamentoScreenState createState() => _EditarOrcamentoScreenState();
}

class _EditarOrcamentoScreenState extends State<EditarOrcamentoScreen> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _descontoController = TextEditingController(
    text: '0',
  );
  List<Map<String, dynamic>> _produtos = [];
  double _valorTotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarOrcamento();
  }

  Future<void> _carregarOrcamento() async {
    try {
      setState(() => _isLoading = true);
      final orcamento = await DatabaseHelper.instance.getOrcamentoById(
        widget.orcamentoId,
      );

      if (orcamento != null) {
        setState(() {
          _clienteController.text = orcamento['cliente']?.toString() ?? '';
          _descontoController.text = (orcamento['desconto'] ?? 0.0).toString();
          _produtos = List<Map<String, dynamic>>.from(
            orcamento['produtos'] ?? [],
          );
          _calcularValorTotal();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar orçamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calcularValorTotal() {
    double total = 0.0;
    for (var produto in _produtos) {
      total +=
          (produto['preco'] as num).toDouble() *
          (produto['quantidade'] as num).toInt();
    }
    double desconto = double.tryParse(_descontoController.text) ?? 0.0;
    setState(() {
      _valorTotal = total - desconto;
    });
  }

  Future<void> _atualizarOrcamento() async {
    if (_clienteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.updateOrcamento({
        'id': widget.orcamentoId,
        'cliente': _clienteController.text.trim(),
        'desconto': double.tryParse(_descontoController.text) ?? 0.0,
        'produtos': _produtos,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar orçamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removerProduto(int index) {
    setState(() {
      _produtos.removeAt(index);
      _calcularValorTotal();
    });
  }

  void _editarProduto(int index) {
    final produto = _produtos[index];
    final nomeController = TextEditingController(
      text: produto['nome']?.toString(),
    );
    final precoController = TextEditingController(
      text: (produto['preco'] as num).toString(),
    );
    final quantidadeController = TextEditingController(
      text: (produto['quantidade'] as num).toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Produto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nome = nomeController.text.trim();
                  final preco =
                      double.tryParse(
                        precoController.text.replaceAll(',', '.'),
                      ) ??
                      0.0;
                  final quantidade =
                      int.tryParse(quantidadeController.text) ?? 1;

                  if (nome.isNotEmpty && preco > 0 && quantidade > 0) {
                    setState(() {
                      _produtos[index] = {
                        'nome': nome,
                        'preco': preco,
                        'quantidade': quantidade,
                      };
                      _calcularValorTotal();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  void _adicionarProduto() {
    final nomeController = TextEditingController();
    final precoController = TextEditingController();
    final quantidadeController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Adicionar Produto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nome = nomeController.text.trim();
                  final preco =
                      double.tryParse(
                        precoController.text.replaceAll(',', '.'),
                      ) ??
                      0.0;
                  final quantidade =
                      int.tryParse(quantidadeController.text) ?? 1;

                  if (nome.isNotEmpty && preco > 0 && quantidade > 0) {
                    setState(() {
                      _produtos.add({
                        'nome': nome,
                        'preco': preco,
                        'quantidade': quantidade,
                      });
                      _calcularValorTotal();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  Widget _buildProdutoItem(int index) {
    final produto = _produtos[index];
    final preco = (produto['preco'] as num).toDouble();
    final quantidade = (produto['quantidade'] as num).toInt();
    final total = preco * quantidade;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    produto['nome']?.toString() ?? 'Produto sem nome',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editarProduto(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerProduto(index),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantidade: $quantidade'),
                Text(
                  'Preço: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(preco)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _clienteController,
                              decoration: const InputDecoration(
                                labelText: 'Cliente',
                                border: OutlineInputBorder(),
                                hintText: 'Nome do cliente',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _descontoController,
                              decoration: const InputDecoration(
                                labelText: 'Desconto (R\$)',
                                border: OutlineInputBorder(),
                                prefixText: 'R\$ ',
                                hintText: '0,00',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (value) => _calcularValorTotal(),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _adicionarProduto,
                              icon: const Icon(Icons.add, color: Colors.black),
                              label: const Text(
                                'Adicionar Produto',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_produtos.isNotEmpty)
                              ..._produtos.asMap().entries.map(
                                (entry) => _buildProdutoItem(entry.key),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Valor Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$',
                                decimalDigits: 2,
                              ).format(_valorTotal),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _atualizarOrcamento,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                              : const Text(
                                'Salvar Alterações',
                                style: TextStyle(color: Colors.black),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
