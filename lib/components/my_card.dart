import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final void Function()? onTap;
  final Widget child;
  final double? width;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const MyCard({
    super.key,
    this.onTap,
    required this.child,
    this.width,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width ?? MediaQuery.of(context).size.width,
        ),
        child: Card(
          margin: margin ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
