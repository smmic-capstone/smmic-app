import 'package:flutter/cupertino.dart';
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

class _MyGridBoxState extends State<MyGridBox> with AutomaticKeepAliveClientMixin {
  final Color _color = const Color.fromARGB(255, 254, 255, 255);
  final List<String> _text = ['NOTIFICATION', 'DEVICE', ' IRRIGATION'];
  final List<Widget> _pages = [
    const NotifPage(),
    const Devices(key: PageStorageKey<String>('devicesPage')),
    const Irrigation()
  ];
  final List<String> _imagePaths = [
    'assets/notibell.png',
    'assets/device.png',
    'assets/irrigation.png',
  ];
  final PageStorageBucket bucket = PageStorageBucket();

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      key: const PageStorageKey('devices'),
      bucket: bucket,
      child: Container(
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
          ),
    );
  }
}
