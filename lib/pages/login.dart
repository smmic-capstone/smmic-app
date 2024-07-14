import 'package:flutter/material.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/pages/dashboard.dart';
import 'package:smmic/pages/register.dart';
import 'package:smmic/subcomponents/login/mybutton.dart';
import 'package:smmic/subcomponents/login/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool obscurepassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(231, 231, 231, 1),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              SafeArea(
                  child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 50),
                    child: ListTile(
                      title: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        'Enter your email and password to continue',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w100,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0, top: 100, left: 8.0, right: 8.0),
                    child: MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(Icons.person),
                      ),
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyTextField(
                      controller: passController,
                      hintText: 'Password',
                      obscuretext: obscurepassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurepassword = !obscurepassword;
                              });
                            },
                            color: Colors.black.withOpacity(0.7),
                            icon: Icon(obscurepassword
                                ? Icons.visibility_off
                                : Icons.visibility)),
                      ),
                    ),
                  ),
                  Padding(
                      padding:
                          const EdgeInsets.only(right: 35, top: 5, bottom: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 10),
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 30, top: 20),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Mybutton(onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyBottomNav(
                                        indexPage: 0,
                                      )));
                        })),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Register()));
                        },
                        child: const Text(
                          'Don t have an account? Sign Up',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ))
            ],
          ),
        ));
  }
}
