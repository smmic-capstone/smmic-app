import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/subcomponents/login/textfield.dart';
import 'package:smmic/subcomponents/manageacc/labeltext.dart';
import 'package:smmic/subcomponents/manageacc/textfield.dart';
import 'package:http/http.dart' as http;
import 'package:smmic/utils/shared_prefs.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccount();
}

class _ManageAccount extends State<ManageAccount>{
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
  final UserDataServices _userDataServices = UserDataServices();



  /*Future<Map<String,dynamic>> getUserDetails() async {
    String baseURL = 'http://localhost:8000/api';
    String apiURL = '$baseURL/djoser/users/me/';
    SharedPreferences userToken = await SharedPreferences.getInstance();
    String? token = userToken.getString('access');

    if (token == null) {
      throw Exception("No token found");
    }

    try{
      final response = await http.get(Uri.parse(apiURL),
      headers: {"Authorization":"Bearer $token"});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }else{
        throw Exception("Failed to fetch user data;");
      }
    }catch(error){
      throw Exception("Wrong Credentials");
    }
  }*/

  @override
  Widget build(BuildContext context){
    return FutureBuilder<Map<String,dynamic>?>(
      future: getUserDetails.getUserInfo(token: context.watch<AuthProvider>().accessData!.token),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }else if (snapshot.hasError){
          return Center(child: Text("Error: ${snapshot.error}"));
        }else if (snapshot.hasData) {
          final userJsonData = snapshot.data!;
          SharedPrefsUtils().userData(userInfo: userJsonData);
          setFirstNameController.text = userJsonData['first_name'];
          setLastNameController.text = userJsonData['last_name'];
          setProvinceController.text = userJsonData['province'];
          setCityController.text = userJsonData['city'];
          setBarangayController.text = userJsonData['barangay'];
          setZoneController.text = userJsonData['zone'];
          setZipCodeController.text = userJsonData['zip_code'];
          setEmailController.text = userJsonData['email'];
          setPasswordController.text = userJsonData['password'].toString().substring(0, 10);
          String firstName = userJsonData['first_name'];
          String lastName = userJsonData ['last_name'];
          String profilePicture = userJsonData["profilepic"];
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
                            backgroundImage: NetworkImage(profilePicture)
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(firstName,style: const TextStyle(fontSize: 26),),
                              Text(lastName,style: const TextStyle(fontSize: 26),),
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
        }else{
          return const Center(child:Text("No data for this user"));
        }
      }
    );
  }
}