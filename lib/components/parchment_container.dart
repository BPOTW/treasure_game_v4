import 'package:flutter/material.dart';

class ParchmentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const ParchmentContainer({
    super.key, 
    required this.child, 
    this.padding = const EdgeInsets.all(24)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBD6),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20, spreadRadius: -5)],
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
