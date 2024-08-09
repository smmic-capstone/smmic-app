import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/models/user_data_model.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/subcomponents/manageacc/labeltext.dart';
import 'package:smmic/subcomponents/manageacc/textfield.dart';
import 'package:smmic/utils/logs.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccount();
}

class _ManageAccount extends State<ManageAccount>{
  final Logs _logs = Logs(tag: 'accountinfo.dart');

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
  Widget build(BuildContext context){
    User? userData = context.watch<UserDataProvider>().user;
    UserAccess? accessData = context.watch<AuthProvider>().accessData;

    if(userData == null){
      _logs.warning(message: 'userData from UserDataProvider is null: $userData');

      _logs.warning(message: 'userData from UserDataProvider is null: $accessData');
      throw Exception('error: user data == null!');
    }

    setFirstNameController.text = userData.firstName;
    setLastNameController.text = userData.lastName;
    setProvinceController.text = userData.firstName;
    setCityController.text = userData.city;
    setBarangayController.text = userData.barangay;
    setZoneController.text = userData.zone;
    setZipCodeController.text = userData.zipCode;
    setEmailController.text = userData.email;
    setPasswordController.text = userData.password.toString().substring(0, userData.password.length < 10 ? userData.password.length : 10);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Manage Account"),
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(userData!.profilePicLink)
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData.firstName, style: const TextStyle(fontSize: 26),),
                        Text(userData.lastName, style: const TextStyle(fontSize: 26),),
                        const Text("Edit Profile"),
                      ],
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: LabelText(label: "Email"),
              ),
              ManageAccountTextField(controller: setEmailController,
                  disableInput: true,
                  hintText: "Email",
                  obscuretext: false),

              const LabelText(label: "First Name"),
              ManageAccountTextField(controller: setFirstNameController,
                  hintText: "First Name",
                  obscuretext: false),

              const LabelText(label: "Last Name"),
              ManageAccountTextField(controller: setLastNameController,
                  hintText: "Last Name",
                  obscuretext: false),

              const LabelText(label: "Province"),
              ManageAccountTextField(controller: setProvinceController,
                  hintText: "Province",
                  obscuretext: false),

              const LabelText(label: "City"),
              ManageAccountTextField(controller: setCityController,
                hintText: "City",
                obscuretext: false,),

              const LabelText(label: "Barangay"),
              ManageAccountTextField(controller: setBarangayController,
                  hintText: "Barangay",
                  obscuretext: false),

              const LabelText(label: "Zone"),
              ManageAccountTextField(controller: setZoneController,
                  hintText: "Zone",
                  obscuretext: false),

              const LabelText(label: "Zip Code"),
              ManageAccountTextField(controller: setZipCodeController,
                  hintText: "Zip Code",
                  obscuretext: false),

              const LabelText(label: "Password"),
              ManageAccountTextField(controller: setPasswordController,
                  disableInput: true,
                  hintText: "Password",
                  obscuretext: true)
            ],
          )
        ],
      ),
    );
  }
}