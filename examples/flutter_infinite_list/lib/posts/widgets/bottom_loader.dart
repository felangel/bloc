import 'package:flutter/material.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({
    required this.callback, super.key,
  });
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    callback();
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}
