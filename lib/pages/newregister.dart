import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/subcomponents/login/newlogintextfield.dart';

import '../providers/theme_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    final firstname = TextEditingController();
    final lastname = TextEditingController();
    final province = TextEditingController();
    final city = TextEditingController();
    final barangay = TextEditingController();
    final zone = TextEditingController();
    final zipcode = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool obscurepassword = true;


    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color backgroundColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(13, 13, 13, 1)
        : const Color.fromRGBO(255, 255, 255, 1);

    Color notActiveTab = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(41, 54, 79, .5)
        : const Color.fromRGBO(164, 164, 164, .5);

    Color activeTab = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(67, 177, 255, 1)
        : const Color.fromRGBO(194, 161, 98, 1);

    Color hintTextColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(255, 255, 255, 1)
        : const Color.fromRGBO(13, 13, 13, 1);

    Color textFieldBorder = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(45, 59, 89, 1)
        : const Color.fromRGBO(194, 161, 98, 1);

    Widget customTabBar(/*{required bool isActive}*/){
      return Container(
        width: width * 0.3,
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          /*color: isActive ? activeTab : notActiveTab,*/
        ),
      );
    }

    Widget firstTabView(){
      return Column(
        children: [
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              controller: firstname,
              hintText: 'First Name',
              obscureText: false
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              controller: lastname,
              hintText: 'Last Name',
              obscureText: false
          ),

        ],
      );
    }

    Widget secondTabView(){
      return Column(
        children: [
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Province Name';
                }
                return null;
              },
              controller: province,
              hintText: 'Province',
              obscureText: false
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a City Name';
                }
                return null;
              },
              controller: city,
              hintText: 'City',
              obscureText: false
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Barangay Name';
                }
                return null;
              },
              controller: barangay,
              hintText: 'Barangay',
              obscureText: false
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Zone';
                }
                return null;
              },
              controller: zone,
              hintText: 'Zone',
              obscureText: false
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your zip code';
                }
                return null;
              },
              controller: zipcode,
              hintText: 'Zip Code',
              obscureText: false
          )
        ],
      );
    }

    Widget thirdTabView(){
      return Column(
        children: [
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Zone';
                }else if (!EmailValidator.validate(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              controller: emailController,
              hintText: 'Email',
              obscureText: false
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Zone';
                }
                return null;
              },
              controller: passController,
              hintText: 'Password',
              obscureText: true
          ),
          NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Zone';
                }else if(value != passController.text){
                  return 'Password not matching';
                }
                return null;
              },
              controller: passController,
              hintText: 'Confirm Password',
              obscureText: true
          ),
        ],
      );
    }

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .05),
            child: Column(
              children:[
                Container(
                  width: width * 0.4,
                  height: height * 0.4,
                  color: Colors.red,
                ),
               TabBar(
                   dividerColor: Colors.transparent,
                   controller: _tabController,
                   indicator: BoxDecoration(
                     color: activeTab, // Active tab color
                     borderRadius: BorderRadius.circular(100),
                   ),
                   unselectedLabelColor: notActiveTab,
                    tabs: [
                      customTabBar(/*isActive: _tabController.index == 0*/ ),
                      customTabBar(/*isActive: _tabController.index == 1*/ ),
                      customTabBar(/*isActive: _tabController.index == 2*/ )
                    ]
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Center(child: firstTabView()),
                      Center(child: secondTabView()),
                      Center(child: thirdTabView()),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(1); // Navigate to the second tab
                  },
                  child: Text('Go to Second Tab'),
                ),

              ],
            ),
          ),

        ),

    );
  }
}