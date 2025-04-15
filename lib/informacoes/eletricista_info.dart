import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EletricistaInfo extends StatelessWidget {
  const EletricistaInfo({super.key});

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
        backgroundColor: const Color.fromARGB(255, 55, 52, 53),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Armazenamento Local de Dados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Seus orçamentos e anotações são salvos localmente no seu dispositivo usando o banco de dados SQLite:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            const Text(
              'Como Funciona o Armazenamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Banco de dados SQLite: Tecnologia consolidada usada em milhões de apps',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Dados salvos em arquivo criptografado no seu dispositivo',
                  ),
                  SizedBox(height: 8),
                  Text('• Acesso rápido mesmo sem internet'),
                  SizedBox(height: 8),
                  Text('• Capacidade para milhares de orçamentos e anotações'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Onde os Dados são Armazenados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Pasta privada do aplicativo (não acessível por outros apps)',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Caminho típico: /data/data/net.aindustrial.app/databases/',
                  ),
                  SizedBox(height: 8),
                  Text('• Arquivo principal: app_database.db'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Segurança e Privacidade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✔️ Seus dados nunca saem do seu dispositivo'),
                  SizedBox(height: 8),
                  Text(
                    '✔️ Nenhuma informação é enviada para servidores externos',
                  ),
                  SizedBox(height: 8),
                  Text('✔️ Criptografia básica do arquivo de banco de dados'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Riscos e Cuidados Importantes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Troca de dispositivo: Os dados não são transferidos automaticamente',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Desinstalação: Todos os dados locais serão perdidos se o app for desinstalado',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Root/desbloqueio: Dispositivos modificados podem ter segurança comprometida',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            InkWell(
              onTap:
                  () =>
                      launchUrl(Uri.parse('https://sqlite.org/security.html')),
              child: const Text(
                '🔗 Mais sobre segurança do SQLite (site oficial)',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
