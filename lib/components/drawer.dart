import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/models/user_data_model.dart';
import 'package:smmic/pages/QRcode.dart';
import 'package:smmic/pages/accountinfo.dart';
import 'package:smmic/pages/lab.dart';
import 'package:smmic/pages/local_connect.dart';
import 'package:smmic/pages/settings.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/imageSource.dart';
import 'package:smmic/utils/logs.dart';

class ComponentDrawer extends StatefulWidget {
  const ComponentDrawer({super.key});

  @override
  State<ComponentDrawer> createState() => ComponentDrawerState();
}

class ComponentDrawerState extends State<ComponentDrawer> {
  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  final AuthUtils _authUtils = AuthUtils();
  final ApiRequest _apiRequest = ApiRequest();
  final Logs _logs = Logs(tag: 'accountinfo.dart');

  @override
  Widget build(BuildContext context) {
    User? userData = context.watch<UserDataProvider>().user;
    UserAccess? accessData = context.watch<AuthProvider>().accessData;

    if (userData == null) {
      _logs.warning(
          message: 'userData from UserDataProvider is null: $userData');

      _logs.warning(
          message: 'userData from UserDataProvider is null: $accessData');
      throw Exception('error: user data == null!');
    }
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: Row(
            children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _image != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            'https://static.thenounproject.com/png/5034901-200.png'),
                      ),
              )),
              Text(
                userData.firstName,
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
              title: const Text('Manage Account'),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpiryColorChangeWidget(
                              expiryTime: DateTime.now().add(
                            const Duration(seconds: 10),
                          ))));
            },
            child: const ListTile(
              leading: Icon(Icons.science_outlined),
              title: Text('Lab'),
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
            onTap: () {
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
            onTap: () {
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
