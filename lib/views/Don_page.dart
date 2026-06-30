import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  final String monCash = "+509 XXXX XXXX";
  final String natCash = "+509 XXXX XXXX";
  final String paypal = "https://paypal.me/eRead";

  Future<void> _launchPaypal() async {
    final uri = Uri.parse(paypal);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copié dans le presse-papiers"),
      ),
    );
  }

  Widget paymentCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onCopy,
    VoidCallback? onOpen,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            SelectableText(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy),
                    label: const Text("Copier"),
                  ),
                ),

                if (onOpen != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Ouvrir"),
                    ),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soutenir eRead"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 70,
          ),

          const SizedBox(height: 15),

          const Text(
            "Merci de soutenir eRead ❤️",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "Votre soutien nous permet d'ajouter davantage de livres, de développer de nouvelles fonctionnalités, d'améliorer l'application et de continuer à offrir une excellente expérience de lecture à toute la communauté. Chaque contribution, quelle que soit sa valeur, fait une réelle différence. Merci de faire grandir eRead avec nous !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          paymentCard(
            context: context,
            icon: Icons.phone_android,
            color: Colors.orange,
            title: "MonCash",
            value: monCash,
            onCopy: () => _copy(context, monCash),
          ),

          const SizedBox(height: 15),

          paymentCard(
            context: context,
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            title: "NatCash",
            value: natCash,
            onCopy: () => _copy(context, natCash),
          ),

          const SizedBox(height: 15),

          paymentCard(
            context: context,
            icon: Icons.language,
            color: Colors.green,
            title: "PayPal",
            value: paypal,
            onCopy: () => _copy(context, paypal),
            onOpen: _launchPaypal,
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              "Merci pour votre soutien 💜",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}