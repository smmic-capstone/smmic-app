import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/drawer.dart';
import 'package:smmic/components/grid/gridbox.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/subcomponents/weatherComponents/weatherWidgets.dart';
import 'package:smmic/pages/forcastpage.dart';
import 'package:smmic/providers/theme_provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  Stream<String> _currentTimeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final hours = now.hour % 12 == 0 ? 12 : now.hour % 12;
      final minutes = now.minute.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? "PM" : "AM";
      return "$hours:$minutes $period";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(14, 14, 14, 1)
          : const Color.fromRGBO(230, 230, 230, 1),
      drawer: const ComponentDrawer(),
      body: Stack(
        children: [
          _drawCircle(),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForcastPage())
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 20
                    ),
                    height: 150,
                    child: const Center(
                      child: WeatherComponentsWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            child: _appBar(),
          )
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(),
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              );
            },
          ),
          Text(
            'Hi ${context.watch<UserDataProvider>().user!.firstName}!',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white
            ),
          ),
          const SizedBox(width: 10),
          StreamBuilder(
            stream: _currentTimeStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                  ),
                );
              } else {
                return const Text(
                  '00:00 AM',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter'
                  ),
                );
              }
            }
          ),
          GestureDetector(
            onTap: () {
              context.read<UiProvider>().changeTheme();
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: context.watch<UiProvider>().isDark
                  ? SvgPicture.asset('assets/icons/clear_night.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        Color.fromRGBO(98, 245, 255, 1),
                        BlendMode.srcATop
                    ),
                  )
                  : SvgPicture.asset('assets/icons/clear_day2.svg',
                    width: 23,
                    height: 23,
                    colorFilter: const ColorFilter.mode(
                        Color.fromRGBO(255, 232, 62, 1),
                        BlendMode.srcATop
                    ),
                  ),
            ),
          ),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget _drawCircle() {
    return Positioned(
      top: -200,
      left: MediaQuery.of(context).size.width / 2 - 300,
      child: Container(
        width: 600,
        height: 600,
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