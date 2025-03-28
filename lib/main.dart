import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vibration/vibration.dart'; // Adicionei aqui
import 'residencial.dart';
import 'motores.dart';
import 'tela3.dart';
import 'eletricista.dart';
import 'orcamento.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaPrincipal(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(300, 100)),
        ),
      ),
      routes: {
        '/orcamentos': (context) => Orcamento(),
        '/residencial': (context) => Residencial(),
        '/motores': (context) => Motores(),
        '/informacoes': (context) => Tela3(),
        '/eletricista': (context) => Eletricista(),
      },
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  final Color corChumbo = const Color.fromARGB(255, 55, 52, 53);

  final List<Map<String, dynamic>> botoes = [
    {
      'texto': 'Residencial',
      'rota': '/residencial',
      'icone': Icons.home,
      'cor': Colors.deepPurple,
    },
    {
      'texto': 'Motores',
      'rota': '/motores',
      'icone': Icons.engineering,
      'cor': Colors.blue,
    },
    {
      'texto': 'Eletricista',
      'rota': '/eletricista',
      'icone': Icons.electrical_services,
      'cor': Colors.green,
    },
    {
      'texto': 'Informações',
      'rota': '/informacoes',
      'icone': Icons.info,
      'cor': Colors.orange,
    },
  ];

  TelaPrincipal({super.key});

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
    // Método de vibração encapsulado
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Erro na vibração: $e');
    }
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
                    botao['rota'] as String,
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
    String rota,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () async {
          await _vibrar(); // Vibração antes da navegação
          Navigator.push(context, _customPageRoute(_getScreen(rota)));
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

  Widget _getScreen(String rota) {
    switch (rota) {
      case '/residencial':
        return Residencial();
      case '/motores':
        return Motores();
      case '/eletricista':
        return Eletricista();
      case '/informacoes':
        return Tela3();
      case '/orcamentos':
        return Orcamento();
      default:
        return const SizedBox.shrink();
    }
  }
}
