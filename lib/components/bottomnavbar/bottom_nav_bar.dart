import 'package:flutter/material.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/notification.dart';

class MyBottomNav extends StatefulWidget {
  final int? indexPage;
  const MyBottomNav({super.key, required this.indexPage});

  @override
  State<MyBottomNav> createState() => _MyBottomNavState();
}

class _MyBottomNavState extends State<MyBottomNav> {
  int myCurrentIndex = 0;
  List<Widget> pages = [const DashBoard(), const Notifications(), const Devices()];

  @override
  void initState() {
    super.initState();
    myCurrentIndex = widget.indexPage ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(8, 20))
        ]),
        child: ClipRRect(
          child: BottomNavigationBar(
            backgroundColor: Color.fromARGB(255, 36, 36, 36),
            selectedItemColor: Color.fromARGB(255, 90, 89, 89),
            unselectedItemColor: Color.fromARGB(255, 251, 246, 246),
            currentIndex: myCurrentIndex,
            onTap: (index) {
              setState(() {
                myCurrentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: "Notifications"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_tree), label: "Devices")
            ],
          ),
        ),
      ),
      body: pages[myCurrentIndex],
    );
  }
}
