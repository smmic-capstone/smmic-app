import 'package:flutter/material.dart';
import 'package:smmic/subcomponents/register/textfieldRegister.dart';

class MyTextField extends StatefulWidget{
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool? disableInput;
  final IconData? icon;
  final Widget? suffixIcon;
  final double opacity; // Add an opacity parameter
  final String? Function(String?) validator;
  final EdgeInsets? padding;

  const MyTextField(
      {super.key,
        required this.validator,
        required this.controller,
        required this.hintText,
        required this.obscureText,
        this.disableInput,
        this.icon,
        this.suffixIcon,
        this.opacity = 0.9,
        this.padding
      });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 25.0),
      child: Opacity(
        opacity: widget.opacity,
        child: TextFormField(
          validator: widget.validator,
          enabled: !(widget.disableInput ?? false),
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            prefix: widget.icon != null ? Icon(widget.icon) : null,
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
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.black),
            suffixIcon: widget.suffixIcon,
          ),
        ),
      ),
    );
  }
}
