import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'residencial_info.dart';
import 'motores_info.dart';
import 'eletricista_info.dart';

class Informacoes extends StatefulWidget {
  const Informacoes({super.key});

  @override
  State<Informacoes> createState() => _InformacoesState();
}

class _InformacoesState extends State<Informacoes> {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);

  final List<Map<String, dynamic>> botoes = [
    {
      'texto': 'Residencial',
      'rota': ResidencialInfo(),
      'icone': Icons.home,
      'cor': Colors.deepPurple,
    },
    {
      'texto': 'Motores',
      'rota': MotoresInfo(),
      'icone': Icons.engineering,
      'cor': Colors.blue,
    },
    {
      'texto': 'Eletricista',
      'rota': EletricistaInfo(),
      'icone': Icons.electrical_services,
      'cor': Colors.green,
    },
  ];

  PageRouteBuilder _customPageRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
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
    );
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

  Widget _buildButton(String text, Widget rota, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () async {
          await _vibrar();
          if (!mounted) return;
          Navigator.push(context, _customPageRoute(rota));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: Color.lerp(color, Colors.transparent, 0.7),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    botao['texto'] as String,
                    botao['rota'] as Widget,
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
}
