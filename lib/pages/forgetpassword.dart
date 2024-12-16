import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/pages/newlogin.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/subcomponents/login/mybutton.dart';
import 'package:smmic/subcomponents/login/newlogintextfield.dart';
import 'package:smmic/utils/logs.dart';

import '../utils/api.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final Logs _logs = Logs(tag: "Forget Password");

  final TextEditingController emailController = TextEditingController();

  bool isButtonDisabled = true;

  void updateButtonState() {
    setState(() {
      // Enable the button if the TextField is not empty
      isButtonDisabled = disableButton();
    });
  }

  bool disableButton(){
    return emailController.text.isEmpty;
  }

  @override
  void initState(){
    super.initState();
    emailController.addListener(updateButtonState);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void forgetPassword({required String email}) async {
    try{
      final response = await _apiRequest.post(route: _apiRoutes.forgetPassword,
          body: {
        'email' : email,
      });
      if (response.containsKey('error')) {
        if(response['error'] == 400){
          ///TODO:Error Handle
          _logs.error(message: "error in forget password");
        }
      }else if(response.containsKey('status_code')){
        if(response['status_code'] == 204 && context.mounted){
          WidgetsBinding.instance.addPostFrameCallback((_){
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context){
                  return AlertDialog(
                    title: const Text("Email Confirmation"),
                    content: const Text("We've sent a password reset link to your email. If you don't see it, please check your spam or junk folder."),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pushReplacement((context), MaterialPageRoute(builder: (context) => const LoginPage()));
                      }, child: const Text("OK"))
                    ],
                  );
                });
          });
        }

      }
    }catch(e){
      _logs.error(message: "Error in sending email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color backgroundColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(13, 13, 13, 1)
        : const Color.fromRGBO(255, 255, 255, 1);

    Color hintTextColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(255, 255, 255, 1)
        : const Color.fromRGBO(13, 13, 13, 1);

    Color textFieldBorder = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(45, 59, 89, 1)
        : const Color.fromRGBO(194, 161, 98, 1);

    Color textColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(255, 255, 255, .50)
        : const Color.fromRGBO(13, 13, 13, .50);

    String iconPath = context.watch<UiProvider>().isDark
        ? "assets/icons/smmicDark.png"
        : "assets/icons/smmicGold.png";

    return Scaffold(
      backgroundColor: backgroundColor,
      body:Padding(
        padding: EdgeInsets.symmetric(horizontal: height * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  width: width * 0.7,
                  height: height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Image(
                            image: AssetImage(iconPath),
                            width: width * .32,
                            height: height * .14,
                          )
                      ),
                      Center(
                        child: Text("Forget Password",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 34,
                              color: hintTextColor,
                              fontWeight: FontWeight.w400,
                            )
                        ),
                      ),
                      Center(
                        child: Text("Enter your email address",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 15,
                                color: textColor,
                                fontWeight: FontWeight.w400
                            )
                        ),
                      ),
                    ],
                  )
              ),
              Padding(
                padding: EdgeInsets.only(bottom: height * .4),
                child: Center(
                  child: NewMyTextField(
                      textFieldBorderColor: textFieldBorder,
                      hintTextColor: hintTextColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!EmailValidator.validate(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      controller: emailController,
                      hintText: "Email Address",
                      obscureText: false),
                ),
              ),
              Center(
                child: MyButton(
                    onTap: disableButton()
                    ? null : (){
                      ///TODO: logic for sending email link
                      print("wahh");
                      forgetPassword(email: emailController.text);
                    },
                    textColor: disableButton() ? Colors.grey : textFieldBorder,
                    text: "Forgot Password"),
              ),
            ],
          ),
        ),
      )
    );
  }
}