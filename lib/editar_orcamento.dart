import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditarOrcamentoScreen extends StatefulWidget {
  final int orcamentoId;

  const EditarOrcamentoScreen({Key? key, required this.orcamentoId})
    : super(key: key);

  @override
  _EditarOrcamentoScreenState createState() => _EditarOrcamentoScreenState();
}

class _EditarOrcamentoScreenState extends State<EditarOrcamentoScreen> {
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _descontoController = TextEditingController();
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
      setState(() {
        _isLoading = true;
      });

      final orcamento = await DatabaseHelper.instance.getOrcamentoById(
        widget.orcamentoId,
      );

      if (orcamento != null) {
        setState(() {
          _clienteController.text = orcamento['cliente'] ?? '';
          _descontoController.text = (orcamento['desconto'] ?? 0.0).toString();

          if (orcamento['produtos'] != null && orcamento['produtos'] is List) {
            _produtos = List<Map<String, dynamic>>.from(orcamento['produtos']);
          } else {
            _produtos = [];
          }

          _calcularValorTotal();
        });
      }
    } catch (e) {
      print('Erro ao carregar orçamento: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar orçamento: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calcularValorTotal() {
    double total = 0.0;
    for (var produto in _produtos) {
      total += produto['preco'] * produto['quantidade'];
    }
    double desconto = double.tryParse(_descontoController.text) ?? 0;
    setState(() {
      _valorTotal = total - desconto;
    });
  }

  void _atualizarOrcamento() async {
    final orcamento = {
      'id': widget.orcamentoId,
      'cliente': _clienteController.text,
      'desconto': double.tryParse(_descontoController.text) ?? 0,
      'valor_total': _valorTotal,
      'produtos': _produtos,
    };

    try {
      await DatabaseHelper.instance.updateOrcamento(orcamento);
      Navigator.pop(context, true);
    } catch (e) {
      print('Erro ao atualizar orçamento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar orçamento: $e')),
      );
    }
  }

  void _removerProduto(int index) {
    setState(() {
      _produtos.removeAt(index);
      _calcularValorTotal();
    });
  }

  void _adicionarProduto(Map<String, dynamic> produto) {
    setState(() {
      _produtos.add(produto);
      _calcularValorTotal();
    });
  }

  void _mostrarDialogoAdicionarProduto() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController precoController = TextEditingController();
    final TextEditingController quantidadeController = TextEditingController();

    quantidadeController.text = '1';

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
                  ),
                ),
                TextFormField(
                  controller: precoController,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: quantidadeController,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final nome = nomeController.text;
                  final preco = double.tryParse(precoController.text) ?? 0.0;
                  final quantidade =
                      int.tryParse(quantidadeController.text) ?? 1;

                  if (nome.isNotEmpty && preco > 0) {
                    _adicionarProduto({
                      'nome': nome,
                      'preco': preco,
                      'quantidade': quantidade,
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nome e preço são obrigatórios'),
                      ),
                    );
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Orçamento')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _clienteController,
                      decoration: const InputDecoration(labelText: 'Cliente'),
                    ),
                    TextFormField(
                      controller: _descontoController,
                      decoration: const InputDecoration(labelText: 'Desconto'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calcularValorTotal(),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _mostrarDialogoAdicionarProduto,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Produto'),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Produtos (${_produtos.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    Expanded(
                      child:
                          _produtos.isEmpty
                              ? const Center(
                                child: Text('Nenhum produto adicionado'),
                              )
                              : ListView.builder(
                                itemCount: _produtos.length,
                                itemBuilder: (context, index) {
                                  return _ProdutoItem(
                                    produto: _produtos[index],
                                    onRemove: () => _removerProduto(index),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'Total: R\$ ${_valorTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _atualizarOrcamento,
                        child: const Text('Salvar Alterações'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _ProdutoItem extends StatelessWidget {
  final Map<String, dynamic> produto;
  final VoidCallback onRemove;

  const _ProdutoItem({Key? key, required this.produto, required this.onRemove})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(produto['nome']),
        subtitle: Text(
          'Quantidade: ${produto['quantidade']} - Preço: R\$ ${produto['preco']}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
