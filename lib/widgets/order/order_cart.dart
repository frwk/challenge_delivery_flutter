import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final IconData? icons;
  final String title;
  final String content;
  final SizedBox? other;

  const OrderCard({super.key, required this.title, required this.content, this.icons, this.other});

  @override
  Widget build(BuildContext context) {
    return MyCard(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icons),
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            Text(content,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                )),
            if (other != null) other!
          ],
        ));
  }
}
