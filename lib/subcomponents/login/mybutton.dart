import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  const MyButton(
      {super.key,
      required this.onTap,
      required this.textColor,
      required this.text});
  final Function()? onTap;
  final Color textColor;
  final String text;

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 300,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
              color: widget.textColor, borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
