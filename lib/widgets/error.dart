import 'package:flutter/material.dart';

enum ErrorMessageTypeEnum {
  generic,
  noResult,
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final List<Widget>? actions;
  final IconData? icon;

  ErrorMessage({required this.message, this.actions, this.icon});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon!,
                    color: Theme.of(context).colorScheme.primary,
                    size: 50,
                  ),
                const SizedBox(height: 10),
                const Text(
                  'Oups!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (actions != null && actions!.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...actions!
                          .map((action) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: action,
                              ))
                          .toList(),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
