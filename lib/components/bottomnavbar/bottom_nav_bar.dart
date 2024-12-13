import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/pages/QRcode.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/settings.dart';
import 'package:smmic/providers/theme_provider.dart';

class BottomNavBar extends StatefulWidget {
  final int? initialIndexPage;
  const BottomNavBar({super.key, required this.initialIndexPage});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndexPage = 0;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndexPage = index;
    });
  }
  
  final BorderRadius _borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(25),
      topRight: Radius.circular(25)
  );

  List<(Widget, Widget)> _pagesGenerator(bool isDark) {
    List<(Widget, Widget)> pages = [
      (
      const DashBoard(),
      SvgPicture.asset(
        'assets/icons/home.svg',
        clipBehavior: Clip.antiAlias,
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(
          isDark ? Colors.white : Colors.black,
          BlendMode.srcATop
        ),
      )),
      (
      const Devices(),
      SvgPicture.asset(
        'assets/icons/signal.svg',
        clipBehavior: Clip.antiAlias,
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(
            isDark ? Colors.white : Colors.black,
            BlendMode.srcATop
        ),
      )),
      (
      const QRcode(),
      SvgPicture.asset(
          'assets/icons/qr_scanner.svg',
          clipBehavior: Clip.antiAlias,
          width: 30,
          height: 30,
          colorFilter: ColorFilter.mode(
              isDark ? Colors.white : Colors.black, BlendMode.srcATop)
      )),
      /*SvgPicture.asset(
        'assets/icons/settings.svg',
        clipBehavior: Clip.antiAlias,
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(
            isDark ? Colors.white : Colors.black,
            BlendMode.srcATop
        ),
      )),*/
    ];

    return pages;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(14, 14, 14, 1)
          : const Color.fromRGBO(230, 230, 230, 1),
      // appBar: AppBar(),
      body: _pagesGenerator(context.watch<UiProvider>().isDark)[_currentIndexPage].$1,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: context.watch<UiProvider>().isDark
              ? const Color.fromRGBO(29, 29, 29, 1)
              : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 25,
              offset: Offset(8, 20)
            )
          ]
        ),
        child: ClipRRect(
          child: SizedBox(
            height: 65,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ..._buildIconBg(MediaQuery.of(context).size.width, context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ..._buildIcons(context)
                  ],
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  List<Widget> _buildIconBg(double mediaQWidth, BuildContext context) {

    bool isOdd = _pagesGenerator(context.watch<UiProvider>().isDark).length % 2 == 1;
    // too lazy to set logic for even lists
    // for now, this operation will throw an
    // exception with even lists :>>>>>
    if (!isOdd) {
      throw Exception('Page list defined with BottomNavBar must be odd!');
    }

    return _pagesGenerator(context.watch<UiProvider>().isDark).indexed.map((page) {
      int pageIndex = page.$1;
      int pagesLen = _pagesGenerator(context.watch<UiProvider>().isDark).length;
      bool right = pageIndex <= pagesLen ~/ 2;
      bool left = pageIndex >= pagesLen ~/ 2;

      return OverflowBox(
        maxHeight: 500,
        child: IconBg(
            itemIndex: page.$1,
            currentIndex: _currentIndexPage,
            positionIdentifier: (left, right)
        ),
      );

    }).toList();
  }

  List<Widget> _buildIcons(BuildContext context) {
    return _pagesGenerator(context.watch<UiProvider>().isDark).indexed.map((page) {
      return GestureDetector(
        onTap: () {
          setCurrentIndex(page.$1);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 112,
              color: Colors.transparent,
            ),
            page.$2.$2
          ],
        ),
      );
    }).toList();
  }

}

class IconBg extends StatefulWidget {
  final int itemIndex;
  final int currentIndex;
  final (bool, bool) positionIdentifier;

  const IconBg({
    super.key,
    required this.itemIndex,
    required this.currentIndex,
    required this.positionIdentifier
  });

  @override
  State<IconBg> createState() => _IconBgState();
}

class _IconBgState extends State<IconBg> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnim;

  bool isExpanded = false;

  late ValueNotifier<int> _currentIndexNotifier;

  @override
  void initState() {
    super.initState();

    _currentIndexNotifier = ValueNotifier<int>(widget.currentIndex);
    _currentIndexNotifier.addListener(toggleCircle);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500
      ),
    );

    _sizeAnim = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutExpo
      ),
    );
  }

  void toggleCircle() {
    if (_currentIndexNotifier.value == widget.itemIndex) {
      setState(() {
        _animationController.duration = const Duration(milliseconds: 350);
        _animationController.forward();
        isExpanded = true;
      });
    } else {
      setState(() {
        _animationController.duration = const Duration(milliseconds: 200);
        _animationController.reverse();
        isExpanded = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentIndexNotifier.removeListener(toggleCircle);
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IconBg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentIndexNotifier.value = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (widget.currentIndex == 0) {
      toggleCircle();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          alignment: Alignment.center,
          margin: widget.positionIdentifier.$1 && widget.positionIdentifier.$2
              ? null
              : EdgeInsets.only(
                  left: widget.positionIdentifier.$1 ? 225 : 0,
                  right: widget.positionIdentifier.$2 ? 225 : 0,
                ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
                Radius.circular(400)
            ),
            color: context.watch<UiProvider>().isDark
                ? const Color.fromRGBO(234, 234, 234, 0.15)
                : const Color.fromRGBO(215, 215, 215, 1),
          ),
          width: _sizeAnim.value,
          height: _sizeAnim.value,
        );
      },
    );
  }
}