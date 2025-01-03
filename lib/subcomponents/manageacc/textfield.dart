import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';

class ManageAccountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscuretext;
  final bool? disableInput;
  final IconData? icon;
  final Widget? suffixIcon;
  final double opacity; // Add an opacity parameter

  const ManageAccountTextField(
      {super.key,
      this.controller,
      required this.hintText,
      required this.obscuretext,
      this.disableInput,
      this.icon,
      this.suffixIcon,
      this.opacity = 0.9});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5, bottom: 5),
      child: Opacity(
        opacity: opacity,
        child: TextField(
          enabled: !(disableInput ?? false),
          controller: controller,
          obscureText: obscuretext,
          decoration: InputDecoration(
            prefix: icon != null ? Icon(icon) : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                  color: context.watch<UiProvider>().isDark
                      ? const Color.fromRGBO(0, 0, 0, 0)
                      : const Color.fromRGBO(255, 255, 255, 0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.white),
            ),
            fillColor: context.watch<UiProvider>().isDark
                ? const Color.fromRGBO(0, 0, 0, 0)
                : const Color.fromRGBO(255, 255, 255, 0),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
                color: context.watch<UiProvider>().isDark
                    ? Colors.white
                    : Colors.black),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}
