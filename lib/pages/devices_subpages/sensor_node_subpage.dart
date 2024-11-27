import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/sensor_node_subpage/stacked_line.dart';
import 'package:smmic/components/devices/sensor_node_subpage/sensor_node_card_expanded.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import '../../models/device_data_models.dart';

class SensorNodePage extends StatefulWidget {
  const SensorNodePage({
    super.key,
    required this.deviceID,
    this.latitude,
    this.longitude,
    required this.deviceName,
    required this.deviceInfo
  });

  final String deviceID;
  final String? latitude;
  final String? longitude;
  final String deviceName;
  final SensorNode deviceInfo;

  @override
  State<StatefulWidget> createState() => _SensorNodePageState();
}

class _SensorNodePageState extends State<SensorNodePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _appBarBgAnimController;
  late Animation<double> _appBarBgAnimation;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    _appBarBgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500
      ),
    );

    _appBarBgAnimation = Tween<double>(begin: 0, end: 0.90).animate(
      CurvedAnimation(
          parent: _appBarBgAnimController,
          curve: Curves.easeOutExpo
      ),
    );

    super.initState();
  }

  void _onScroll() {
    double scrollOffset = _scrollController.offset;
    if (scrollOffset > 30) {
      setState(() {
        _appBarBgAnimController.duration = const Duration(milliseconds: 500);
        _appBarBgAnimController.forward();
      });
    } else {
      setState(() {
        _appBarBgAnimController.duration = const Duration(milliseconds: 300);
        _appBarBgAnimController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _appBarBgAnimController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.watch<UiProvider>().isDark
            ? const Color.fromRGBO(14, 14, 14, 1)
            : const Color.fromRGBO(230, 230, 230, 1),
        body: Stack(
          children: [
            _drawCircle(),
            SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    _expandedSeCard(),
                    const SizedBox(height: 15),
                    StackedLineChart(deviceId: widget.deviceID),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 45,
              left: (MediaQuery.of(context).size.width / 2)
                  - (MediaQuery.of(context).size.width * 0.90) / 2,
              child: Center(
                child: _appBar(),
              ),
            ),
          ],
        )
    );
  }

  Widget _appBar() {
    const double appBarHeight = 60;
    double appBarWidth = MediaQuery.of(context).size.width * 0.90;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _appBarBgAnimation,
          builder: (context, child) {
            double width = MediaQuery.of(context).size.width * _appBarBgAnimation.value;
            return Transform.translate(
              // TODO: because offset queries screen width, it might break on other devices
                offset: Offset(((MediaQuery.of(context).size.width - width) / 2) - 20, 0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 5.0,
                        sigmaY: 5.0
                    ),
                    child: Container(
                      width: width,
                      height: appBarHeight,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                )
            );
          },
        ),
        Container(
          height: appBarHeight,
          width: appBarWidth,
          decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(100))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 1),
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(CupertinoIcons.arrow_left,
                      size: 27,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(width: 35),
              Text(
                widget.deviceName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(width: 35),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () {
                    context.read<UiProvider>().changeTheme();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: context.watch<UiProvider>().isDark
                        ? SvgPicture.asset('assets/icons/clear_night.svg',
                      width: 27,
                      height: 27,
                      colorFilter: const ColorFilter.mode(
                          Color.fromRGBO(98, 245, 255, 1),
                          BlendMode.srcATop
                      ),
                    )
                        : SvgPicture.asset('assets/icons/clear_day2.svg',
                      width: 27,
                      height: 27,
                      colorFilter: const ColorFilter.mode(
                          Color.fromRGBO(255, 232, 62, 1),
                          BlendMode.srcATop
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _expandedSeCard() {
    return SensorNodeCardExpanded(
      deviceID: widget.deviceID,
    );
  }

  Widget _drawCircle() {
    double width = MediaQuery.of(context).size.width;
    double size = 1.55 * width;
    return Positioned(
      top: -200,
      left: width / 2 - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: context.watch<UiProvider>().isDark
                ? const Color.fromRGBO(45, 59, 89, 1)
                : const Color.fromRGBO(194, 161, 98, 1),
            shape: BoxShape.circle
        ),
      ),
    );
  }

}