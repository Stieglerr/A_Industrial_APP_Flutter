import 'package:flutter/material.dart';
import 'orcamento.dart';
import 'anotacoes.dart';

class Eletricista extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eletricista'),
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
                  MaterialPageRoute(builder: (context) => Orcamento()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 100),
                textStyle: TextStyle(fontSize: 24),
              ),
              child: Text('Orçamento'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Anotacoes()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 100),
                textStyle: TextStyle(fontSize: 24),
              ),
              child: Text('Anotações'),
            ),
          ],
        ),
      ),
    );
  }
}
