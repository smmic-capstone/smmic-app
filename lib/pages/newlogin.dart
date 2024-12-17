import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/pages/forgetpassword.dart';
import 'package:smmic/pages/newregister.dart';
import 'package:smmic/subcomponents/login/newlogintextfield.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_services.dart';
import '../subcomponents/login/mybutton.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// On Submission of Form or the email and password
  Future<void> _onSubmitForm(BuildContext context) async {

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing the dialog while loading
        builder: (context) =>
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging in...'),
            ],
          ),
        ),
      );
      try {
        await _authService.login(
            email: _emailController.text, password: _passwordController.text);
        if (context.mounted) {
          Navigator.of(context).pop();
          context.read<AuthProvider>().init();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthGate()),
                  (route) => false);
        }
      }catch(e){
        if(context.mounted){
          Navigator.of(context).pop();

          // Show error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    ///MediaQuery width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    ///Colors of the UI/Containers/TextFields
    Color backgroundColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(45, 59, 89, 1)
        : const Color.fromRGBO(194, 161, 98, 1);

    Color pocketColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(13, 13, 13, 1)
        : const Color.fromRGBO(255, 255, 255, 1);

    Color backPocketColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(13, 13, 13, 0.5)
        : const Color.fromRGBO(231, 222, 204, 1);

    Color textFieldBorder = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(45, 59, 89, 1)
        : const Color.fromRGBO(194, 161, 98, 1);

    Color hintTextColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(255, 255, 255, 1)
        : const Color.fromRGBO(13, 13, 13, 1);

    Color iconColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(255, 255, 255, .50)
        : const Color.fromRGBO(13, 13, 13, .50);



    ///Form Widget consists of the email and passwords text fields and the Forgot Password
    Widget form(TextEditingController emailController,
        TextEditingController passwordController) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: height * 0.08),
            child: const Text(
              "Welcome!",
              style: TextStyle(fontFamily: 'Inter', fontSize: 36),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.05),
            child: const Text("Login to your SMMIC account",
                style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
          ),
          NewMyTextField(
            hintTextColor: hintTextColor,
            textFieldBorderColor: textFieldBorder,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!EmailValidator.validate(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            controller: emailController,
            hintText: 'Email',
            obscureText: false,
            suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(
                  Icons.person,
                  color: iconColor,
                )),
            padding: EdgeInsets.zero,
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.01),
            child: NewMyTextField(
              hintTextColor: hintTextColor,
              textFieldBorderColor: textFieldBorder,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              controller: passwordController,
              hintText: 'Password',
              obscureText: obscurePassword,
              suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      color: Colors.black.withOpacity(0.7),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: iconColor,
                      ))),
              padding: EdgeInsets.zero,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.05),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  ///TODO: Create logic for forget password
                },
                child: GestureDetector(
                  onTap: (){
                    Navigator.push((context), MaterialPageRoute(builder: (context) => const ForgetPassword()));
                  },
                    child: Text(
                  'Forgot Password',
                  style: TextStyle(
                      color: iconColor,
                      decoration: TextDecoration.underline,
                      fontSize: 11),
                ),)

              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.1),
            child: Align(
                alignment: Alignment.center,
                child: MyButton(
                  onTap: () async {
                    print("Button is pressed");
                    await _onSubmitForm(context);
                  },
                  textColor: textFieldBorder,
                  text: 'Login',
                )),
          ),
          Padding(
              padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an Account? ",
                  style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 12,
                      color: iconColor)
                ),
                GestureDetector
                  (onTap: (){
                    Navigator.push((context), MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                    child: Text("Register",
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: iconColor),
                    )
                )
              ],
            )
          ),
        ],
      );
    }

    ///pocket Container Widget
    Widget pocketContainer() {
      return Container(
          height: height * 0.698,
          width: width,
          padding: EdgeInsets.symmetric(horizontal: width * .100),
          decoration: BoxDecoration(
              color: pocketColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50))),
          child: Form(
              key: _formKey,
              child: form(_emailController, _passwordController)
          )
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Container(
                width: width,
                height: height,
                color: backgroundColor,
                alignment: AlignmentDirectional.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: height * 0.005),
                  child: Image(
                    image: const AssetImage('assets/icons/smmic.png'),
                    width: width * .5,
                    height: height * .230,
                  ),
                )),
            Container(
              height: height * 0.710,
              width: width * 0.8265,
              decoration: BoxDecoration(
                  color: backPocketColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
            ),
            pocketContainer()
          ],
        ),
      ),
    );
  }
}
