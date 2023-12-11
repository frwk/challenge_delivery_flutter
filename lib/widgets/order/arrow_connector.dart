import 'package:flutter/material.dart';

class ArrowConnector extends StatelessWidget {
  const ArrowConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 80,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.orangeAccent,
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}
