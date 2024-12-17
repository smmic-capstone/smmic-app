import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:smmic/pages/newlogin.dart';
import 'package:smmic/pages/newregister.dart';
import 'package:smmic/pages/settings.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
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

  TextStyle itemTextStyle(bool isDark) {
    return TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontFamily: 'Inter',
      fontSize: 19,
      fontWeight: FontWeight.w400
    );
  }

  @override
  Widget build(BuildContext context) {
    User? userData = context.watch<UserDataProvider>().user;
    bool isDark = context.watch<UiProvider>().isDark;
    UserAccess? accessData = context.watch<AuthProvider>().accessData;

    /*if (userData == null) {
      _logs.warning(
          message: 'userData from UserDataProvider is null: $userData');

      _logs.warning(
          message: 'userData from UserDataProvider is null: $accessData');
      throw Exception('error: user data == null!');
    }*/

    return Drawer(
      backgroundColor: isDark ? const Color.fromRGBO(21, 21, 21, 1) : Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
              child: Row(
                children: [
                  Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                        child: _image != null
                            ? CircleAvatar(radius: 30, backgroundImage: MemoryImage(_image!))
                            : const CircleAvatar(radius: 30,backgroundImage: NetworkImage('https://static.thenounproject.com/png/5034901-200.png'),),
                      )
                  ),
                  Text(
                    userData!.firstName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              )
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
            child: ListTile(
                contentPadding: const EdgeInsets.only(left: 30, top: 5, bottom: 5),
                leading: SvgPicture.asset(
                  'assets/icons/settings.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.black,
                      BlendMode.srcIn
                  ),
                ),
                title: Text('Settings', style: itemTextStyle(isDark))
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 30, top: 5, bottom: 5),
              leading: SvgPicture.asset(
                'assets/icons/profile.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn
                ),
              ),
              title: Text(
                  'Manage Account',
                style: itemTextStyle(isDark),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageAccount()));
              },
            ),
          ),
         /* GestureDetector(
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
          ),*/
          /*GestureDetector(
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
          ),*/
          /*GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const QRcode()));
            },
            child: const ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('QR'),
            ),
          ),*/
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _authUtils.logoutUser(context);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 30, top: 5, bottom: 5),
              leading: SvgPicture.asset(
                'assets/icons/logout.svg',
                width: 23,
                height: 22,
                colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn
                ),
              ),
              title: Text(
                  "Logout",
                style: itemTextStyle(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
