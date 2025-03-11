import 'package:flutter/material.dart';
import 'residencial.dart';
import 'motores.dart';
import 'tela3.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaPrincipal(),
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'A Industrial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Residencial()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 100),
                textStyle: TextStyle(fontSize: 24),
              ),
              child: Text('Residencial'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Motores()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 100),
                textStyle: TextStyle(fontSize: 24),
              ),
              child: Text('Motores'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tela3()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 100),
                textStyle: TextStyle(fontSize: 24),
              ),
              child: Text('Informações'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
