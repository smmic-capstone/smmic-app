import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/pages/QRcode.dart';
import 'package:smmic/pages/accountinfo.dart';
import 'package:smmic/pages/lab.dart';
import 'package:smmic/pages/local_connect.dart';
import 'package:smmic/pages/settings.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/auth_utils.dart';

class ComponentDrawer extends StatefulWidget {
  const ComponentDrawer({super.key});

  @override
  State<ComponentDrawer> createState() => ComponentDrawerState();
}

class ComponentDrawerState extends State<ComponentDrawer> {
  final AuthUtils _authUtils = AuthUtils();
  final ApiRequest _apiRequest = ApiRequest();

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              child: Row(
            children: [
              Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              )),
              Text(
                'Jozua Cyd, Rubio',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          )),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
            child: const ListTile(
                leading: Icon(Icons.settings_sharp), title: Text('Settings')),
          ),
          GestureDetector(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text('Manage Account'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageAccount()));
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocalConnect()));
            },
            child: const ListTile(
              leading: Icon(Icons.signal_wifi_connected_no_internet_4),
              title: Text('Connect Locally'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ExpiryColorChangeWidget(expiryTime: DateTime.now().add(Duration(seconds: 10),))));
            },
            child: const ListTile(
              leading: Icon(Icons.science_outlined), title: Text('Lab'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const QRcode()));
            },
            child: const ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('QR'),
            ),
          ),
          GestureDetector(
            onTap: (){
              print("Hello World");
              _apiRequest.sendIntervalCommand(
                  eventName: EventNames.irrigationCommand.events);
            },
            child: const ListTile(
              leading: Icon(Icons.water_drop_outlined),
              title: Text('Send Interval Command'),
            ),
          ),
          GestureDetector(
            onTap: (){
              print("Hello World z");
              _apiRequest.sendIrrigationCommand(
                  eventName: EventNames.irrigationCommand.events,
              commands: Commands.irrigationON.toString());
            },
            child: const ListTile(
              leading: Icon(Icons.water_drop_outlined),
              title: Text('Send Irrigation Command'),
            ),
          ),
          GestureDetector(
            onTap: (){
              _authUtils.logoutUser(context);
            },
            child: const ListTile(
              leading: Icon(Icons.power_settings_new),
              title: Text("Logout"),
            ),
          )
        ],
      ),
    );
  }
}
