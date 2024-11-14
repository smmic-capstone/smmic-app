import 'dart:async';
import 'package:flutter/material.dart';

class ExpiryColorChangeWidget extends StatefulWidget {
  final DateTime expiryTime;

  ExpiryColorChangeWidget({required this.expiryTime});

  @override
  _ExpiryColorChangeWidgetState createState() => _ExpiryColorChangeWidgetState();
}

class _ExpiryColorChangeWidgetState extends State<ExpiryColorChangeWidget> {
  Color _currentColor = Colors.green; // Initial color
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startExpiryTimer();
  }

  void _startExpiryTimer() {
    Duration timeUntilExpiry = widget.expiryTime.difference(DateTime.now());

    _timer = Timer(timeUntilExpiry, () {
      setState(() {
        _currentColor = Colors.red; // Change color on expiry
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: _currentColor,
      child: Center(child: Text('Expires Soon')),
    );
  }
}
