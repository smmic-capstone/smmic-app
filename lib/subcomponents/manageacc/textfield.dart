import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.only(left: 25.0,right: 25, bottom: 25),
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
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.white),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}
