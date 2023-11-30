import 'package:flutter/material.dart';

class ButtonAtom extends StatelessWidget {
  final String data;
  final String? redirectTo;

  const ButtonAtom({super.key, required this.data, this.redirectTo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:22.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () => {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent[200],
            fixedSize: const Size(400, 50),
          ),
          child: Text(
              data,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )
          ),
        ),
      ),
    );
  }
}
