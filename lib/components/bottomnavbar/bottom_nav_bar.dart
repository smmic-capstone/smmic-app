import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/notification.dart';
import 'package:smmic/pages/settings.dart';
// import 'package:dartz/dartz.dart';

class BottomNavBar extends StatefulWidget {
  final int? initialIndexPage;
  const BottomNavBar({super.key, required this.initialIndexPage});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndexPage = 0;

  final BorderRadius _borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(25),
      topRight: Radius.circular(25)
  );

  final List<(Widget, Widget)> _pages = [
    (
    const DashBoard(),
    SvgPicture.asset(
      'assets/icons/home.svg',
      clipBehavior: Clip.antiAlias,
      width: 30,
      height: 30,
    )),
    (
    const Devices(),
    SvgPicture.asset(
      'assets/icons/signal.svg',
      clipBehavior: Clip.antiAlias,
      width: 30,
      height: 30,
    )),
    (
    const Settings(),
    SvgPicture.asset(
      'assets/icons/settings.svg',
      clipBehavior: Clip.antiAlias,
      width: 32,
      height: 32,
    )),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndexPage = widget.initialIndexPage ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: _pages[_currentIndexPage].$1,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 25,
              offset: Offset(8, 20)
            )
          ]
        ),
        child: ClipRRect(
          child: Container(
            height: 70,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ..._buildIcons()
                  ],
                ),
                ..._buildIconBg(MediaQuery.of(context).size.width),
              ],
            ),
          ),
        )
      ),
    );
  }

  List<Widget> _buildIconBg(double mediaQWidth) {
    double mediaQDivided = mediaQWidth / _pages.length;

    bool isOdd = _pages.length % 2 == 1;

    // too lazy to set logic for even lists
    // for now, this operation will throw an
    // exception with even lists :>>>>>
    if (!isOdd) {
      throw Exception('Page list defined with BottomNavBar must be odd!');
    }

    return _pages.indexed.map((page) {

      int pageIndex = _pages.indexOf(page.$2);
      bool right = pageIndex <= _pages.length ~/ 2;
      bool left = pageIndex >= _pages.length ~/ 2;

      return Positioned(
          top: -14.5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentIndexPage = page.$1;
              });
            },
            child: ClipRRect(
              child: Container(
                margin: EdgeInsets.only(
                  left: left ? 225 : 0,
                  right: right ? 225 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(400)
                  ),
                  color: Colors.black.withOpacity(
                      _currentIndexPage == page.$1 ? 0.15 : 0
                  ),
                ),
                width: 100,
                height: 100,
              ),
            ),
          )
      );
    }).toList();
  }

  List<Widget> _buildIcons() {
    return _pages.map((page) {
      return Container(
        child: page.$2,
      );
    }).toList();
  }

}

class CustomBottomNavigationBarItem extends BottomNavigationBarItem {
  const CustomBottomNavigationBarItem({
    super.key,
    required super.icon,
    super.label = ''
  });
}