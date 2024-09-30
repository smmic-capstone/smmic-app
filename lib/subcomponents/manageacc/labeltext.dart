import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';

class LabelText extends StatelessWidget {
  const LabelText({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: Text(
        label,
        style: TextStyle(
            color: context.watch<UiProvider>().isDark
                ? Colors.white
                : Colors.black),
      ),
    );
  }
}
