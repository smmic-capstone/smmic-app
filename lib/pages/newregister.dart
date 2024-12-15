import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/pages/newlogin.dart';
import 'package:smmic/subcomponents/login/mybutton.dart';
import 'package:smmic/subcomponents/login/newlogintextfield.dart';
import 'package:smmic/utils/api.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../providers/theme_provider.dart';
import '../utils/logs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final Logs _logs = Logs(tag: 'Register Page');

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

  bool obscurePassword = true;
  bool isButtonDisabled = true;

  final pageController = PageController(initialPage: 0);
  int currentPageIndex = 0;

  void updateButtonState() {
    setState(() {
      // Enable the button if the TextField is not empty
      isButtonDisabled = disableButton();
    });
  }

  bool disableButton() {
    if (currentPageIndex == 0) {
      return firstname.text.isEmpty || lastname.text.isEmpty;
    } else if (currentPageIndex == 1) {
      return province.text.isEmpty ||
          city.text.isEmpty ||
          barangay.text.isEmpty ||
          zone.text.isEmpty ||
          zipcode.text.isEmpty;
    } else if (currentPageIndex == 2) {
      return emailController.text.isEmpty ||
          passController.text.isEmpty ||
          confirmPassController.text.isEmpty;
    }
    return true; // Default to disabling scrolling if something unexpected happens
  }

  @override
  void initState() {
    firstname.addListener(updateButtonState);
    lastname.addListener(updateButtonState);
    province.addListener(updateButtonState);
    barangay.addListener(updateButtonState);
    city.addListener(updateButtonState);
    zone.addListener(updateButtonState);
    zipcode.addListener(updateButtonState);
    emailController.addListener(updateButtonState);
    passController.addListener(updateButtonState);
    confirmPassController.addListener(updateButtonState);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void register({
    required String firstname,
    required String lastname,
    required String province,
    required String city,
    required String barangay,
    required String zone,
    required String zipCode,
    required String email,
    required String password,
    required String confirmPassword}) async {

    try{
      final response =  await _apiRequest.post(
          route: _apiRoutes.register,
          body: {
            'first_name':firstname,
            'last_name':lastname,
            'province':province,
            'city' : city,
            'barangay':barangay,
            'zone':zone,
            'zip_code':zipCode,
            'email':email,
            'password':password,
            're_password':confirmPassword,
          });
      if(response.containsKey('error')){
        if(response['error'] == 400){
          ///TODO:Error Handle
          _logs.error(message: "error in registering");
        }
      }else if(response.containsKey('status_code')){
        if(response['status_code'] == 201 && context.mounted){
          Navigator.pushReplacement((context), MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      }
    }catch(e){
      _logs.error(message: "register not working: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ///Keys for the List.generate for text fields
    final List<Map<String, dynamic>> nameFieldData = [
      {
        'controller': firstname,
        'hintTextNames': 'First Name',
        'validator': (String? value) {
          if (value == null || value.isEmpty) {
            return "Please input your first name";
          }
          return null;
        },
        'obscureText': false
      },
      {
        'controller': lastname,
        'hintTextNames': 'Last Name',
        'validator': (String? value) {
          if (value == null || value.isEmpty) {
            return "Please input your last name";
          }
          return null;
        },
        'obscureText': false
      }
    ];

    final List<Map<String, dynamic>> provinceFieldData = [
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Province Name';
          }
          return null;
        },
        'controller': province,
        'hintText': 'Province',
        'obscureText': false
      },
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a City Name';
          }
          return null;
        },
        'controller': city,
        'hintText': 'City',
        'obscureText': false
      },
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Barangay Name';
          }
          return null;
        },
        'controller': barangay,
        'hintText': 'Barangay',
        'obscureText': false
      },
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Zone';
          }
          return null;
        },
        'controller': zone,
        'hintText': 'Zone',
        'obscureText': false
      },
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your zip code';
          }
          return null;
        },
        'controller': zipcode,
        'hintText': 'Zip Code',
        'obscureText': false
      }
    ];

    final List<Map<String, dynamic>> credentialsFieldData = [
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Zone';
          } else if (!EmailValidator.validate(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
        'controller': emailController,
        'hintText': 'Email',
        'obscureText': false
      },
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Zone';
          }
          return null;
        },
        'controller': passController,
        'hintText': 'Password',
        'obscureText': obscurePassword
      },
      {
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Zone';
          } else if (value != passController.text) {
            return 'Password not matching';
          }
          return null;
        },
        'controller': confirmPassController,
        'hintText': 'Confirm Password',
        'obscureText': obscurePassword
      }
    ];

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

    Color textColor = context.watch<UiProvider>().isDark
        ? const Color.fromRGBO(255, 255, 255, .50)
        : const Color.fromRGBO(13, 13, 13, .50);


    String iconPath = context.watch<UiProvider>().isDark
        ? "assets/icons/smmicDark.png"
        : "assets/icons/smmicGold.png";

    Widget firstTabView() {
      return Column(
        children: List.generate(2, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NewMyTextField(
                textFieldBorderColor: textFieldBorder,
                hintTextColor: hintTextColor,
                validator: nameFieldData[index]['validator'],
                controller: nameFieldData[index]['controller'],
                hintText: nameFieldData[index]['hintTextNames'],
                obscureText: nameFieldData[index]['obscureText']),
          );
        }),
      );
    }

    Widget secondTabView() {
      return Column(
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NewMyTextField(
                textFieldBorderColor: textFieldBorder,
                hintTextColor: hintTextColor,
                validator: provinceFieldData[index]['validator'],
                controller: provinceFieldData[index]['controller'],
                hintText: provinceFieldData[index]['hintText'],
                obscureText: provinceFieldData[index]['obscureText']),
          );
        }),
      );
    }

    Widget thirdTabView() {
      return Column(
          children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NewMyTextField(
              textFieldBorderColor: textFieldBorder,
              hintTextColor: hintTextColor,
              validator: credentialsFieldData[index]['validator'],
              controller: credentialsFieldData[index]['controller'],
              hintText: credentialsFieldData[index]['hintText'],
              obscureText: credentialsFieldData[index]['obscureText']),
        );
      }));
    }

    Widget textPerIndex(){
      if (currentPageIndex == 0){
        return const Column(
          children: [
            Text("Full Name",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 36,
                    fontWeight: FontWeight.w400
                )
            ),
            Text("Enter your full name",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                ),
            ),
          ],
        );
      }else if(currentPageIndex == 1){
        return const Column(
          children: [
            Text("Address",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 36,
                    fontWeight: FontWeight.w400
                )
            ),
            Text("Provide your complete address",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 15,
                    fontWeight: FontWeight.w400
                )
            )
          ],
        );
      }else{
        return const Column(
          children: [
            Text("Account",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 36,
                    fontWeight: FontWeight.w400
                )),
            Text("Set up your account details",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                )
            ),
          ],
        );
      }
    }


    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: width * 0.6,
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
                        child: textPerIndex(),
                      )
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: 3,
                      effect: SlideEffect(
                          spacing: 8.0,
                          radius: 100,
                          dotWidth: 88,
                          dotHeight: 10,
                          strokeWidth: 1.5,
                          dotColor: notActiveTab,
                          activeDotColor: activeTab),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.4,
                  child: PageView(
                    physics: _RestrictedScrollPhysics(canScrollForward: !disableButton()),
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    children: [
                      Center(child: firstTabView()),
                      Center(child: secondTabView()),
                      Center(child: thirdTabView())
                    ],
                  ),
                ),
                Center(
                  child: MyButton(
                    onTap: disableButton()
                        ? null : () {
                      if (currentPageIndex < 2) {
                        print("button pressed");
                        pageController.jumpToPage(currentPageIndex + 1,);
                      }else if(currentPageIndex == 2){
                        print("button pressed");
                        register(
                            firstname: firstname.text,
                            lastname: lastname.text,
                            province: province.text,
                            city: city.text,
                            barangay: barangay.text,
                            zone: zone.text,
                            zipCode: zipcode.text,
                            email: emailController.text,
                            password: passController.text,
                            confirmPassword: confirmPassController.text
                        );
                      }
                    },
                    textColor: disableButton() ? Colors.grey : textFieldBorder,
                    text: currentPageIndex < 2 ? 'Next' : 'Done',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                        style: TextStyle(
                      fontFamily: "Inter",
                      color: textColor,
                      fontSize: 12)
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement((context), MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      child: Text("Login",style: TextStyle(
                          fontFamily: "Inter",
                          color: textColor,
                          decoration: TextDecoration.underline,
                          fontSize: 12)
                      ),
                    )
                  ],
                                ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestrictedScrollPhysics extends ScrollPhysics {
  bool isGoingRight = false;
  final bool canScrollForward;

   _RestrictedScrollPhysics(
      {required this.canScrollForward, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  _RestrictedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _RestrictedScrollPhysics(canScrollForward: canScrollForward, parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    isGoingRight = offset.sign > 0;
    return offset;
  }
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    //print("applyBoundaryConditions");
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
                'The proposed new position, $value, is exactly equal to the current position of the '
                'given ${position.runtimeType}, ${position.pixels}.\n'
                'The applyBoundaryConditions method should only be called when the value is '
                'going to actually change the pixels, otherwise it is redundant.\n'
                'The physics object in question was:\n'
                '  $this\n'
                'The position object in question was:\n'
                '  $position\n');
      }
      return true;
    }());
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) {
      // overscroll
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      // hit top edge

      return value - position.minScrollExtent;
    }

    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      // hit bottom edge
      return value - position.maxScrollExtent;
    }
    /// if !isGoingRight then that is equal to true which means that value is greater than position.pixels
    /// if isGoingRight then that is equal to false which means that value is less than position.pixels
    /// canScrollForward is true default value
    /// so !canScrollForward is false
    ///

    if(!canScrollForward && !isGoingRight){
      return value;
    }
    return 0.0;
  }
}
