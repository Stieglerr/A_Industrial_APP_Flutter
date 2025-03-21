import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class NovoOrcamentoScreen extends StatefulWidget {
  const NovoOrcamentoScreen({super.key});

  @override
  _NovoOrcamentoScreenState createState() => _NovoOrcamentoScreenState();
}

class _NovoOrcamentoScreenState extends State<NovoOrcamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteController = TextEditingController();
  final List<Map<String, TextEditingController>> _produtos = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  double _valorTotal = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adicionarProduto();
  }

  void _adicionarProduto() {
    setState(() {
      _produtos.add({
        'descricao': TextEditingController(),
        'valor': TextEditingController(),
      });
    });
  }

  void _removerProduto(int index) {
    if (_produtos.length > 1) {
      setState(() {
        _produtos.removeAt(index);
        _calcularTotal();
      });
    }
  }

  void _calcularTotal() {
    double total = 0.0;
    for (var produto in _produtos) {
      final valorTexto = produto['valor']!.text.replaceAll(RegExp(r','), '.');
      final valor = double.tryParse(valorTexto) ?? 0.0;
      total += valor;
    }
    setState(() {
      _valorTotal = total;
    });
  }

  Future<void> _salvarOrcamento() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final produtos =
            _produtos.map((produto) {
              return {
                'descricao': produto['descricao']!.text.trim(),
                'valor': double.parse(
                  produto['valor']!.text.replaceAll(RegExp(r','), '.'),
                ),
              };
            }).toList();

        await _dbHelper.insertOrcamento({
          'cliente': _clienteController.text.trim(),
          'produtos': produtos,
          'valor_total': _valorTotal,
        });

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Orçamento'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _clienteController,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    border: OutlineInputBorder(),
                    hintText: 'Nome do cliente',
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Informe o cliente' : null,
                ),
                const SizedBox(height: 20),
                ..._produtos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final produto = entry.value;
                  return _ProdutoItem(
                    key: ValueKey(index),
                    descricaoController: produto['descricao']!,
                    valorController: produto['valor']!,
                    onRemover: () => _removerProduto(index),
                    onChanged: _calcularTotal,
                    mostrarBotaoRemover: _produtos.length > 1,
                  );
                }).toList(),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _adicionarProduto,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Produto'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTotalCard(),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Valor Total:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _salvarOrcamento,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child:
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Salvar Orçamento'),
    );
  }
}

class _ProdutoItem extends StatefulWidget {
  final TextEditingController descricaoController;
  final TextEditingController valorController;
  final VoidCallback onRemover;
  final VoidCallback onChanged;
  final bool mostrarBotaoRemover;

  const _ProdutoItem({
    required super.key,
    required this.descricaoController,
    required this.valorController,
    required this.onRemover,
    required this.onChanged,
    required this.mostrarBotaoRemover,
  });

  @override
  __ProdutoItemState createState() => __ProdutoItemState();
}

class __ProdutoItemState extends State<_ProdutoItem> {
  final _valorFocusNode = FocusNode();

  @override
  void dispose() {
    _valorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Instalação de luminária',
                ),
                textInputAction: TextInputAction.next,
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onChanged: (value) => widget.onChanged(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: widget.valorController,
                focusNode: _valorFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) return 'Informe o valor';
                  final cleanedValue = value.replaceAll(RegExp(r','), '.');
                  final parsed = double.tryParse(cleanedValue);
                  if (parsed == null) return 'Valor inválido';
                  if (parsed <= 0) return 'Valor deve ser positivo';
                  return null;
                },
                onChanged: (value) => widget.onChanged(),
              ),
            ),
            if (widget.mostrarBotaoRemover)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: widget.onRemover,
                tooltip: 'Remover produto',
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
