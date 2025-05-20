import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AIndustrial extends StatelessWidget {
  const AIndustrial({super.key});

  Future<void> _launchWhatsApp(String phone, String message) async {
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }

  Future<void> _launchMapsUrl(String url, BuildContext context) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Não foi possível abrir o mapa';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o aplicativo de mapas'),
          ),
        );
      }
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isClickable ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: const Color.fromARGB(255, 55, 52, 53)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 55, 52, 53),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content,
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                  if (isClickable)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        'Toque para abrir',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
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
        backgroundColor: const Color.fromARGB(255, 55, 52, 53),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.bolt,
                size: 80,
                color: Color.fromARGB(255, 0, 168, 89),
              ),
              const SizedBox(height: 10),

              const Text(
                'A Industrial Materiais Elétricos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sobre Nós',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'A Industrial Materiais Elétricos é especializada em fornecer produtos elétricos de alta qualidade para residências, indústrias e profissionais da área. Nossa equipe está pronta para te atender e ajudar a encontrar os melhores produtos para suas necessidades.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 30),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Localização',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Endereço físico:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Rua Afonso Pena, 1122 - Centro',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed:
                          () => _launchMapsUrl(
                            'https://maps.app.goo.gl/q8htGFRpN1vVea2R6',
                            context,
                          ),
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text(
                        'Abrir no Google Maps',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 55, 52, 53),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildInfoCard(
                icon: Icons.schedule,
                title: 'Horário de Atendimento',
                content:
                    'Segunda a Sexta: 7:00 às 11:30 e 13:00 às 18:00\nSábado: 7:00 às 11:30',
              ),
              const SizedBox(height: 15),

              _buildInfoCard(
                icon: Icons.phone,
                title: 'Contato',
                content: 'WhatsApp: (42) 99842-0106',
                isClickable: true,
                onTap:
                    () => _launchWhatsApp(
                      '5542998420106',
                      'Olá, preciso de ajuda em relação ao aplicativo.',
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
