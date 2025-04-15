import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';

class MotoresInfo extends StatelessWidget {
  const MotoresInfo({super.key});

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
              'Informações Técnicas para Motores Elétricos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Dados complementares para dimensionamento de circuitos de motores conforme normas ABNT:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Links para normas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap:
                      () => launchUrl(
                        Uri.parse(
                          'https://www.guiadaengenharia.com/wp-content/uploads/2019/02/tabelas-completas-5410.pdf',
                        ),
                      ),
                  child: const Text(
                    '🔗 NBR 5410 - Instalações Elétricas',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap:
                      () => launchUrl(
                        Uri.parse(
                          'http://www2.uesb.br/biblioteca/wp-content/uploads/2022/03/NBR-17094-M%C3%81QUINAS-EL%C3%89TRICAS-GIRANTES-PARTE-1-MOTORES-DE-INDU%C3%87%C3%83O-TRIF%C3%81SICOS-REQUESITOS.pdf',
                        ),
                      ),
                  child: const Text(
                    '🔗 NBR 17094 - Motores de Indução',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Seção 1 - Fatores de Influência
            const Text(
              'Fatores que Impactam no Dimensionamento',
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
                    '• Temperatura Ambiente:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Acima de 30°C requer redução na capacidade de condução',
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Método de Instalação:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Eletrodutos embutidos vs. bandejas alteram a dissipação térmica',
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Tipo de Partida:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Partida direta exige maior capacidade que estrela-triângulo',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Seção 2 - Cálculo Teórico
            const Text(
              'Fórmulas para Dimensionamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Math.tex(
                    r'I_{nom} = \frac{P_{kW} \times 1000}{\sqrt{3} \times V \times \eta \times \cos\phi}',
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  Math.tex(
                    r'I_{partida} \approx 6 \times I_{nom} \text{ (partida direta)}',
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Onde:'),
                  Text('• P = Potência em kW (1CV ≈ 0.7355kW)'),
                  Text('• V = Tensão entre fases (V)'),
                  Text('• η = Rendimento do motor (0.7 a 0.95)'),
                  Text('• cosφ = Fator de potência (0.8 a 0.92)'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // NOVA SEÇÃO: Exemplo Prático
            const Text(
              'Exemplo Prático de Cálculo',
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
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Motor Trifásico de 5CV em 380V:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Math.tex(
                    r'\begin{aligned}'
                    r'&P = 5\ \text{CV} \times 735{,}5 = 3677{,}5\ \text{W} \\'
                    r'&I = \frac{3677{,}5}{\sqrt{3} \times 380 \times 0{,}88 \times 0{,}85} \\'
                    r'&I = \frac{3677{,}5}{1{,}732 \times 380 \times 0{,}748} \\'
                    r'&I = \frac{3677{,}5}{492{,}3} \approx 7{,}47\ \text{A}'
                    r'\end{aligned}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Valores utilizados:',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const Text('• Rendimento (η) = 0,88'),
                  const Text('• Fator de potência (cosφ) = 0,85'),
                  const SizedBox(height: 10),
                  const Text(
                    'Corrente de partida estimada (6× Inominal):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Math.tex(
                    r'I_{partida} \approx 6 \times 7{,}47 \approx 44{,}8\ \text{A}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Este valor de corrente nominal (7,47A) é usado para dimensionar:',
              style: TextStyle(fontSize: 15),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Bitola dos condutores'),
                  Text('• Disjuntor (25A para este exemplo)'),
                  Text('• Relé térmico (ajustado para ~8,2A)'),
                  Text('• Contator (categoria AC-3)'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Seção 3 - Proteção
            const Text(
              'Proteção de Circuitos para Motores',
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
                  Text(
                    '• Disjuntor: 250% da corrente nominal para partida direta',
                  ),
                  SizedBox(height: 8),
                  Text('• Fusível: 150% a 300% dependendo do tipo de partida'),
                  SizedBox(height: 8),
                  Text('• Contator: Deve suportar a corrente de partida'),
                  SizedBox(height: 8),
                  Text('• Relé Térmico: Ajuste entre 105% e 120% da Inom'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Seção 4 - Avisos
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
                    '⚠️ Requisitos Normativos Importantes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Todo motor deve ter proteção contra:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('  - Sobrecarga (NBR 5410 item 5.3.4)'),
                  Text('  - Curto-circuito (NBR IEC 60947-2)'),
                  SizedBox(height: 10),
                  Text(
                    '• Circuitos acima de 10CV exigem:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('  - Dispositivo de seccionamento visível'),
                  Text('  - Sinalização adequada'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
