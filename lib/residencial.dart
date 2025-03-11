import 'package:flutter/material.dart';
import 'calculadora_fio.dart';
import 'consumo_reais.dart';
import 'calculadora_amperes.dart';
import 'calculadora_eletroduto.dart';
import 'converter_w_va.dart';

class Residencial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculadoras Elétricas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
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
                _buildButton(
                  context,
                  'Calculadora Fio',
                  CalculadoraFio(),
                  Icons.cable,
                  Colors.deepPurple,
                ),
                _buildButton(
                  context,
                  'Consumo R\$',
                  ConsumoReais(),
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildButton(
                  context,
                  'Calculadora Amperes',
                  CalculadoraAmperes(),
                  Icons.flash_on,
                  Colors.orange,
                ),
                _buildButton(
                  context,
                  'Calculadora Eletroduto',
                  CalculadoraEletroduto(),
                  Icons.build,
                  Colors.blue,
                ),
                _buildButton(
                  context,
                  'Converter W em VA',
                  ConverterWVA(),
                  Icons.compare_arrows,
                  Colors.redAccent,
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
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: color.withOpacity(0.3),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
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
