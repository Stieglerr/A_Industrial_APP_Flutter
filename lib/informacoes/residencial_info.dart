import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';

class ResidencialInfo extends StatelessWidget {
  const ResidencialInfo({super.key});

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
              'Calculadora de Bitolas de Fio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Determina a bitola adequada de fios elétricos baseado na corrente (amperagem), conforme a norma NBR 5410.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap:
                  () => launchUrl(
                    Uri.parse(
                      'https://www.guiadaengenharia.com/wp-content/uploads/2019/02/tabelas-completas-5410.pdf',
                    ),
                  ),
              child: const Text(
                '🔗 Consultar Tabela Completa NBR 5410',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '⚠️ Atenção Importante',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Em casos especiais como:',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Ambientes com temperatura acima de 30°C',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '• Muitos fios agrupados no mesmo eletroduto',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '• Circuitos muito longos',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '• Correntes acima de 322A',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Consulte sempre um engenheiro eletricista para avaliação técnica.',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dica Prática:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Para maior segurança, sempre escolha a bitola imediatamente superior quando o valor da corrente estiver próximo do limite do fio.',
              style: TextStyle(fontSize: 16),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              'Calculadora de Consumo Energético',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Calcula o custo de energia baseado na potência do equipamento e tempo de uso:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Math.tex(
                  r'\text{Custo} = \frac{\text{Potência (W)} \times \text{Tempo (h)}}{1000} \times \text{Tarifa (R\$/kWh)}',
                  textStyle: const TextStyle(fontSize: 18),
                ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exemplo Prático:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Math.tex(
                    r'\frac{4500 \times 1}{1000} \times 0{,}63 = 2{,}83\ \text{R\$}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '(Chuveiro de 4500W usado por 1h com kWh a R\$0,63)',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Onde encontrar os dados:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Potência: Na etiqueta do aparelho (ex.: "1500W")'),
                  Text('• Tempo: Medir o uso real em horas'),
                  Text(
                    '• Preço kWh: Na conta de luz ou site da concessionária',
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              'Calculadora de Amperagem',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Calcula a corrente elétrica a partir da potência e tensão do equipamento:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Math.tex(
                  r'I = \frac{P}{V}',
                  textStyle: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Onde:'),
                  Text('• I = Corrente elétrica (Amperes)'),
                  Text('• P = Potência do equipamento (Watts)'),
                  Text('• V = Tensão da rede elétrica (Volts)'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exemplo Prático:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Math.tex(
                    r'\text{Chuveiro de 5500W em 220V: } \frac{5500}{220} = 25\ \text{A}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Isso significa que precisamos de um disjuntor de pelo menos 25A para este chuveiro.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              'Calculadora de Eletrodutos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Dimensiona eletrodutos conforme a NBR 5410, considerando o número e bitola dos cabos:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Math.tex(
                  r'\text{Área mínima} = \frac{\sum(\pi \times r^2)}{\text{Taxa de ocupação}}',
                  textStyle: const TextStyle(fontSize: 18),
                ),
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
                    'Taxas de Ocupação (NBR5410):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('• 1 cabo: 53% do eletroduto'),
                  const Text('• 2 cabos: 31% para cada cabo'),
                  const Text('• 3+ cabos: 40% para cada cabo'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exemplo Prático:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Math.tex(
                    r'\text{3 cabos de 2.5mm² (∅3.1mm): } \frac{3 \times \pi \times 1.55^2}{0.40} \approx 56.63\ \text{mm²}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Eletroduto necessário: 1 1/4" (35.1mm)',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              'Conversor Watts para Volt-Amperes (VA)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Converte potência real (W) em potência aparente (VA) considerando o fator de potência:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Math.tex(
                  r'VA = \frac{W}{FP}',
                  textStyle: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Onde:'),
                  Text('• VA = Potência aparente'),
                  Text('• W = Potência real (Watts)'),
                  Text('• FP = Fator de potência (cos φ)'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Valores Típicos de Fator de Potência:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('• Resistivos (lâmpadas, chuveiros): 1.0'),
                  const Text('• Eletrônicos: 0.95 - 0.99'),
                  const Text('• Motores: 0.80 - 0.92'),
                  const Text('• Transformadores: 0.70 - 0.85'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exemplo Prático:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Math.tex(
                    r'\text{Equipamento de 1000W com FP=0.92: } \frac{1000}{0.92} \approx 1087\ \text{VA}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este é o valor necessário para dimensionar nobreaks e estabilizadores',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
