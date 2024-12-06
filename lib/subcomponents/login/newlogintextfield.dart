import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/subcomponents/register/textfieldRegister.dart';

class NewMyTextField extends StatefulWidget{
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color textFieldBorderColor;
  final Color hintTextColor;
  final bool? disableInput;
  final IconData? icon;
  final Widget? suffixIcon;
  final double opacity; // Add an opacity parameter
  final String? Function(String?) validator;
  final EdgeInsets? padding;

  const NewMyTextField(
      {super.key,
        required this.textFieldBorderColor,
        required this.hintTextColor,
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
  State<NewMyTextField> createState() => _NewMyTextFieldState();
}

class _NewMyTextFieldState extends State<NewMyTextField> {

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
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: widget.textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:  BorderSide(color: widget.textFieldBorderColor),
            ),
            fillColor: Colors.transparent,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: widget.hintTextColor),
            suffixIcon: widget.suffixIcon,
          ),
        ),
      ),
    );
  }
}
