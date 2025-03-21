import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
      home: const TelaPrincipal(),
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
  final List<Map<String, dynamic>> botoes = const [
    {'texto': 'Residencial', 'rota': '/residencial', 'icone': Icons.home},
    {'texto': 'Motores', 'rota': '/motores', 'icone': Icons.engineering},
    {
      'texto': 'Eletricista',
      'rota': '/eletricista',
      'icone': Icons.electrical_services,
    },
    {'texto': 'Informações', 'rota': '/informacoes', 'icone': Icons.info},
  ];

  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Industrial'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: botoes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final botao = botoes[index];
          return ElevatedButton.icon(
            icon: Icon(botao['icone'], size: 30),
            label: Text(botao['texto'], style: const TextStyle(fontSize: 22)),
            onPressed: () => Navigator.pushNamed(context, botao['rota']),
          );
        },
      ),
    );
  }
}
