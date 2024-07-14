import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool obscuretext;
  final bool? disableInput;
  final IconData? icon;
  final Widget? suffixIcon;
  final double opacity;

  const MyTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      this.labelText,
      required this.obscuretext,
      this.disableInput,
      this.icon,
      this.suffixIcon,
      this.opacity = 0.9})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        enabled: !(disableInput ?? false),
        controller: controller,
        obscureText: obscuretext,
        decoration: InputDecoration(
            prefix: icon != null ? Icon(icon) : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.white),
            ),
            fillColor: Colors.white.withOpacity(opacity),
            filled: true,
            hintText: hintText,
            labelText: labelText,
            hintStyle: const TextStyle(color: Colors.black),
            suffixIcon: suffixIcon),
      ),
    );
  }
}
