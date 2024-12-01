import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/models/user_data_model.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/subcomponents/manageacc/labeltext.dart';
import 'package:smmic/subcomponents/manageacc/textfield.dart';
import 'package:smmic/utils/global_navigator.dart';
import 'package:smmic/utils/imageSource.dart';
import 'package:smmic/utils/logs.dart';

import '../subcomponents/custome _Shape/custom_shape.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccount();
}

class _ManageAccount extends State<ManageAccount> {
  Uint8List? _image;
  //function for selecting image button
  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  final Logs _logs = Logs(tag: 'accountinfo.dart');
  final UserDataServices _userDataServices = UserDataServices();
  final AuthProvider _authProvider = AuthProvider();
  final GlobalNavigator _globalNavigator = locator<GlobalNavigator>();

  UserDataServices getUserDetails = UserDataServices();
  Color? bgColor = const Color.fromRGBO(239, 239, 239, 1.0);
  final setEmailController = TextEditingController();
  final setFirstNameController = TextEditingController();
  final setLastNameController = TextEditingController();
  final setProvinceController = TextEditingController();
  final setCityController = TextEditingController();
  final setBarangayController = TextEditingController();
  final setZoneController = TextEditingController();
  final setZipCodeController = TextEditingController();
  final setPasswordController = TextEditingController();

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

    setFirstNameController.text = userData.firstName;
    setLastNameController.text = userData.lastName;
    setEmailController.text = userData.email;
    setPasswordController.text = userData.password.toString().substring(
        0, userData.password.length < 10 ? userData.password.length : 10);
    setProvinceController.text = userData.province;
    setCityController.text = userData.city;
    setBarangayController.text = userData.barangay;
    setZoneController.text = userData.zone;
    setZipCodeController.text = userData.zipCode;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Manage Account")),
        backgroundColor: context.watch<UiProvider>().isDark
            ? const Color.fromRGBO(45, 59, 89, 1)
            : const Color.fromRGBO(255, 255, 255, 100),
      ),
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(45, 59, 89, 1)
          : Color.fromARGB(255, 255, 255, 255),
      body: Stack(children: [
        _effects(),
        Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: context.watch<UiProvider>().isDark
                          ? const Color.fromRGBO(14, 14, 14, 100)
                          : const Color.fromARGB(194, 161, 98, 1),
                      borderRadius: BorderRadius.circular(25)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          _image != null
                              ? Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4.0)),
                                  child: CircleAvatar(
                                    radius: 64,
                                    backgroundImage: MemoryImage(_image!),
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 70,
                                  backgroundImage: NetworkImage(
                                      'https://static.thenounproject.com/png/5034901-200.png')),
                          Positioned(
                            child: IconButton(
                              onPressed: () {
                                selectImage();
                              },
                              icon: const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              ),
                            ),
                            bottom: -10,
                            left: 88,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData.firstName,
                            style: TextStyle(
                                fontSize: 26,
                                color: context.watch<UiProvider>().isDark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          Text(
                            userData.lastName,
                            style: const TextStyle(fontSize: 26),
                          ),
                          GestureDetector(
                            onTap: () async {
                              UserAccess? _userAccess =
                                  context.read<AuthProvider>().accessData;
                              if (_userAccess == null) {
                                context.read<AuthProvider>().accessStatus ==
                                    TokenStatus.invalid;
                                _globalNavigator.forceLoginDialog(
                                    origin: _logs.tag);
                              } else {
                                Map<String, dynamic> uData = {
                                  'UID': _userAccess.userID,
                                  'first_name': setFirstNameController.text,
                                  'last_name': setLastNameController.text,
                                  'province': setProvinceController.text,
                                  'city': setCityController.text,
                                  'barangay': setBarangayController.text,
                                  'zone': setZoneController.text,
                                  'zip_code': setZipCodeController.text,
                                  'email': setEmailController.text,
                                  'password': setPasswordController.text,
                                  'profilepic': userData.profilePicLink,
                                };
                                await _userDataServices.updateUserInfo(
                                    token: _userAccess.token,
                                    uid: _userAccess.userID,
                                    userData: uData);
                                context
                                    .read<UserDataProvider>()
                                    .userDataChange(uData);
                              }
                            },
                            child: const Text("Edit Profile"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  // Add padding to ListView
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: LabelText(label: "Personal Information"),
                    ),
                    ManageAccountTextField(
                      controller: setEmailController,
                      disableInput: true,
                      hintText: "Email",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setFirstNameController,
                      hintText: "First Name",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setLastNameController,
                      hintText: "Last Name",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setProvinceController,
                      hintText: "Province",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setCityController,
                      hintText: "City",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setBarangayController,
                      hintText: "Barangay",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setZoneController,
                      hintText: "Zone",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setZipCodeController,
                      hintText: "Zip Code",
                      obscuretext: false,
                    ),
                    ManageAccountTextField(
                      controller: setPasswordController,
                      disableInput: true,
                      hintText: "Password",
                      obscuretext: true,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget _effects() {
    double width = MediaQuery.of(context).size.width;
    double size = 1.55 * width;
    return Positioned(
        top: 450,
        left: width / 2 - (size / 2),
        child: ClipPath(
          clipper: RightCurveClipper(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: context.watch<UiProvider>().isDark
                    ? const Color.fromRGBO(14, 14, 14, 100)
                    : const Color.fromRGBO(194, 161, 98, 1),
                shape: BoxShape.circle),
          ),
        ));
  }
}
