import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/subcomponents/login/mybutton.dart';
import 'package:smmic/subcomponents/login/newlogintextfield.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../providers/theme_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
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
      isButtonDisabled = firstname.text.isEmpty;
      isButtonDisabled = lastname.text.isEmpty;
      isButtonDisabled = province.text.isEmpty;
      isButtonDisabled = city.text.isEmpty;
      isButtonDisabled = barangay.text.isEmpty;
      isButtonDisabled = zone.text.isEmpty;
      isButtonDisabled = zipcode.text.isEmpty;
      isButtonDisabled = emailController.text.isEmpty;
      isButtonDisabled = passController.text.isEmpty;
      isButtonDisabled = confirmPassController.text.isEmpty;
    });
  }

  bool disableButton() {
    if (currentPageIndex == 0) {
      return firstname.text.isNotEmpty && lastname.text.isNotEmpty;
    } else if (currentPageIndex == 1) {
      return province.text.isNotEmpty &&
          city.text.isNotEmpty &&
          barangay.text.isNotEmpty &&
          zone.text.isNotEmpty &&
          zipcode.text.isNotEmpty;
    } else if (currentPageIndex == 2) {
      return emailController.text.isNotEmpty &&
          passController.text.isNotEmpty &&
          confirmPassController.text.isNotEmpty;
    }
    return true;
  }

  @override
  void initState() {
    firstname.addListener(updateButtonState);
    lastname.addListener(updateButtonState);
    province.addListener(updateButtonState);
    barangay.addListener(updateButtonState);
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05),
          child: Column(
            children: [
              Container(
                width: width * 0.4,
                height: height * 0.4,
                color: Colors.red,
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
                  physics: _RestrictedScrollPhysics(
                      canScrollForward: disableButton()),
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
                      ? () {
                          if (currentPageIndex < 2) {
                            pageController.animateToPage(currentPageIndex + 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.bounceInOut);
                          }
                        }
                      : null,
                  textColor: disableButton() ? textFieldBorder : Colors.grey,
                  text: currentPageIndex < 2 ? 'Next' : 'Done',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RestrictedScrollPhysics extends ScrollPhysics {
  final bool canScrollForward;

  const _RestrictedScrollPhysics(
      {required this.canScrollForward, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  _RestrictedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _RestrictedScrollPhysics(
        canScrollForward: canScrollForward, parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Restrict forward scrolling
    if (!canScrollForward && value > position.pixels) {
      return value - position.pixels; // Restrict forward scroll
    }
    return 0.0;
  }
}
