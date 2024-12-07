import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  const MyButton({super.key, required this.onTap, required this.textColor});
  final Function()? onTap;
  final Color textColor;

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
            color: widget.textColor,
              borderRadius: BorderRadius.circular(15)),
          child: const Center(
            child: Text('Login',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontSize: 16,
                ),
              ),
          ),
        ),
      ),
    );
  }
}
