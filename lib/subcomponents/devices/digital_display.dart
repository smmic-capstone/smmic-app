import 'package:flutter/material.dart';

class DigitalDisplay extends StatefulWidget {
  const DigitalDisplay({super.key, required this.data, required this.type});

  final String type;
  final dynamic data;

  @override
  State<DigitalDisplay> createState() => _DigitalDisplayState();
}

class _DigitalDisplayState extends State<DigitalDisplay> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 8),
      alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Colors.black12)
        ),
        height: 53,
        width: 73,
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                  text: widget.data.toString(),
                  style: TextStyle(fontSize: 24, fontFamily: 'Inter', color: Colors.black),
                  children: [
                    TextSpan(
                        text: widget.type == 'temperature' ? '°C\n' : widget.type == 'soil moisture' || widget.type == 'humidity' ? '%\n' : '?\n',
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter')
                    ),
                    TextSpan(
                        text: widget.type == 'soil moisture' ? 'Soil Moisture' : widget.type == 'temperature' ? 'Temperature' : widget.type == 'humidity' ? 'Humidity' : 'Unkown',
                        style: const TextStyle(fontSize:9, fontFamily: 'Inter')
                    )
                  ]
              ),
            ),
          ],
        )
    );
  }
}