import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/drawer.dart';
import 'package:smmic/components/grid/gridbox.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/subcomponents/weatherComponents/weatherWidgets.dart';
import 'package:smmic/pages/forcastpage.dart';
import 'package:smmic/providers/theme_provider.dart';

import 'package:smmic/subcomponents/weatherComponents/weatherWidgets.dart';
import 'package:smmic/utils/global_navigator.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    //On app startup, if logged in already
    TokenStatus? accessStatus = context.watch<AuthProvider>().accessStatus;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DASHBOARD',
          style: TextStyle(
              color: context.watch<UiProvider>().isDark
                  ? Colors.white
                  : Colors.black),
        ),
        iconTheme: IconThemeData(
            color: context.watch<UiProvider>().isDark
                ? Colors.white
                : Colors.black),
      ),
      drawer: const ComponentDrawer(),
      body: Consumer<UiProvider>(
        builder: (BuildContext context, UiProvider uiProvider, Widget? child) {
          return ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForcastPage()));
                },
                child: Container(
                  height: 150,
                  width: 350,
                  decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage('assets/background2.jpg'),
                          fit: BoxFit.cover),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 6))
                      ]),
                  child: const Center(
                    child: WeatherComponentsWidget(),
                  ),
                ),
              ),
              const MyGridBox()
            ],
          );
        },
      ),
    );
  }
}
