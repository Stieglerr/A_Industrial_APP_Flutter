import 'package:flutter/material.dart';
import 'calculadora_fio.dart';
import 'consumo_reais.dart';
import 'calculadora_amperes.dart';
import 'calculadora_eletroduto.dart';
import 'converter_w_va.dart';

class Residencial extends StatelessWidget {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);

  final List<Map<String, dynamic>> botoes = [
    {
      'texto': 'Calculadora Fio',
      'pagina': CalculadoraFio(),
      'icone': Icons.cable,
      'cor': Colors.deepPurple,
    },
    {
      'texto': 'Consumo R\$',
      'pagina': ConsumoReais(),
      'icone': Icons.attach_money,
      'cor': Colors.green,
    },
    {
      'texto': 'Calculadora Amperes',
      'pagina': CalculadoraAmperes(),
      'icone': Icons.flash_on,
      'cor': Colors.orange,
    },
    {
      'texto': 'Calculadora Eletroduto',
      'pagina': CalculadoraEletroduto(),
      'icone': Icons.build,
      'cor': Colors.blue,
    },
    {
      'texto': 'Converter W em VA',
      'pagina': ConverterWVA(),
      'icone': Icons.compare_arrows,
      'cor': Colors.redAccent,
    },
  ];

  Residencial({super.key});

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
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final botao in botoes)
                  _buildButton(
                    context,
                    botao['texto'] as String,
                    botao['pagina'] as Widget,
                    botao['icone'] as IconData,
                    botao['cor'] as Color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Widget page,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: color.withOpacity(0.3),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
