import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/cards/sensor_node_card.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/devices/bottom_drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/device_settings_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/utils/logs.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _Devices();
}

class _Devices extends State<Devices> with TickerProviderStateMixin {
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
          _buildList(
            sinkNodeMap: context.watch<DevicesProvider>().sinkNodeMap,
            sensorNodeMap: context.watch<DevicesProvider>().sensorNodeMap,
            options: context.watch<DeviceListOptionsNotifier>().enabledConditions,
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
                      Scaffold.of(context).openDrawer();
                    },
                    child: SvgPicture.asset('assets/icons/menu.svg',
                      width: 27,
                      height: 27,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcATop,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 35),
              const Text(
                'Devices',
                style: TextStyle(
                    color: Colors.transparent,
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

  Widget _buildList({
    required Map<String, SinkNode> sinkNodeMap,
    required Map<String, SensorNode> sensorNodeMap,
    required Map<String, bool Function(Widget)> options,}){

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const SizedBox(height: 125),
          ..._buildCards(
              sinkNodeMap: sinkNodeMap,
              sensorNodeMap: sensorNodeMap,
              options: options
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards({
    required Map<String, SinkNode> sinkNodeMap,
    required Map<String, SensorNode> sensorNodeMap,
    required Map<String, bool Function(Widget)> options}){

    List<Widget> cards = [];

    for (String sinkId in sinkNodeMap.keys) {
      cards.add(
        SinkNodeCard(
          deviceInfo: sinkNodeMap[sinkId]!,
          bottomMargin: 15,
          expanded: false,
        ),
      );
      for (String sensorId in sinkNodeMap[sinkId]!.registeredSensorNodes) {
        cards.add(
          SensorNodeCard(
            deviceInfo: sensorNodeMap[sensorId]!,
            bottomMargin: 15,
          )
        );
      }
    }

    return cards.where((card) {
      return options.keys
          .map((optionKey) => options[optionKey]!(card))
          .any((result) => result);
    }).toList();
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
