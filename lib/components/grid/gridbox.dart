import 'package:flutter/material.dart';
import 'package:smmic/components/grid/gridItem.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/irrigation.dart';
import 'package:smmic/pages/notification.dart';

class MyGridBox extends StatefulWidget {
  const MyGridBox({super.key});

  @override
  State<MyGridBox> createState() => _MyGridBoxState();
}

class _MyGridBoxState extends State<MyGridBox> {
  final Color _color = const Color.fromARGB(255, 254, 255, 255);
  final List<String> _text = ['NOTIFICATION', 'DEVICE', ' IRRIGATION'];
  final List<Widget> _pages = [
    const NotifPage(),
    const Devices(),
    const Irrigation()
  ];
  final List<String> _imagePaths = [
    'assets/notibell.png',
    'assets/device.png',
    'assets/irrigation.png',
  ];

  int _seleectedPageInder = 0;

  void _selectPage(int index) {
    setState(() {
      _seleectedPageInder = index;
    });

    if (index < _pages.length) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => _pages[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        children: List.generate(
            _text.length,
            (index) => GestureDetector(
                onTap: () {
                  _selectPage(index);
                },
                child: GridItem(
                  imagePath: _imagePaths[index],
                  text: _text[index],
                  color: _color,
                ))),
      ),
    );
  }
}
