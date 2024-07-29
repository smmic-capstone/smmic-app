import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smmic/subcomponents/login/textfield.dart';
import 'package:smmic/subcomponents/manageacc/labeltext.dart';
import 'package:smmic/subcomponents/manageacc/textfield.dart';
import 'package:http/http.dart' as http;

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccount();
}

class _ManageAccount extends State<ManageAccount>{
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

  Future<void> getUserDetails() async {
    String baseURL = 'http://127.0.0.1:8000/api';
    String apiURL = '$baseURL/djoser/users/me/';
    String token = 'asdasdsad';
    //token here but how to get from login and store it

    try{
      final response = await http.get(Uri.parse(apiURL),
      headers: {"Authorization":"Bearer $token"});

      if (response.statusCode == 200) {
        final userJsonData = jsonDecode(response.body);
        String uuid = userJsonData['UID'];
        String email = userJsonData['email'];
        String firstName = userJsonData['first_name'];
        String lastName = userJsonData['last_name'];
        String province = userJsonData['province'];
        String city = userJsonData['city'];
        String barangay = userJsonData['barangay'];
        String zone = userJsonData['zone'];
        String zipCode = userJsonData['zip_code'];
        String profilePic = 'http://127.0.0.1/$userJsonData["profilepic"]';
      }else{
        print("Failed to fetch user data;");
      }
    }catch(error){
      print("Wrong Credentials");
    }
  }



  @override
  Widget build(BuildContext context){
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
                color: Colors.blue
              ),
              const LabelText(label: "Email"),
              const ManageAccountTextField( disableInput: true, hintText: "Email", obscuretext: false),

              const LabelText(label: "First Name"),
              ManageAccountTextField(controller:setFirstNameController, hintText: "First Name", obscuretext: false),

              const LabelText( label: "Last Name"),
              ManageAccountTextField(controller: setLastNameController,hintText: "Last Name", obscuretext: false),

              const LabelText(label: "Province"),
              ManageAccountTextField(controller: setEmailController, hintText: "Province", obscuretext: false),

              const LabelText(label: "City"),
              ManageAccountTextField(controller: setCityController, hintText: "City", obscuretext: false,),

              const LabelText(label: "Barangay"),
              ManageAccountTextField(controller: setZoneController, hintText:"Barangay", obscuretext: false),

              const LabelText(label: "Zone"),
              ManageAccountTextField(controller: setZoneController,hintText: "Zone", obscuretext: false),

              const LabelText(label: "Zip Code"),
              ManageAccountTextField(controller:setZipCodeController,hintText: "Zip Code", obscuretext: false),

              const LabelText(label: "Password"),
              ManageAccountTextField(controller: setEmailController, hintText: "Password", obscuretext: false)


            ],
          )
        ],
      ),
    );
  }
}