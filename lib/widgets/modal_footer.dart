import 'package:flutter/material.dart';

class ModalFooter extends StatelessWidget {
  final Widget child;

  const ModalFooter({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Center(child: child),
    );
  }
}
