import 'package:flutter/material.dart';
import 'package:smmic/pages/login.dart';
import 'package:smmic/subcomponents/register/mybuttonRegister.dart';
import 'package:smmic/subcomponents/register/textfieldRegister.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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

  Future<void> registerUser () async {
    String baseURL = 'http://192.168.1.8:8000/api';
    final String registerURL = '$baseURL/djoser/users/';

    try{
      final response = await http.post(Uri.parse(registerURL), body: {
        'first_name' : firstname.text,
        'last_name' : lastname.text,
        'province' : province.text,
        'city' : city.text,
        'barangay' : barangay.text,
        'zone' : zone.text,
        'zip_code' : zipcode.text,
        'email' : emailController.text,
        'password' : passController.text,
        're_password' : confirmPassController.text
    });
      if (response.statusCode == 201 && context.mounted){
        if(!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()
        ));
      }
    }catch(error){
      print('Error registering: $error');
    }
  }

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
                        'Create Account',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        'Fill-up information below to create your account',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w100,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, top: 50, left: 10, right: 10),
                    child: MyTextField(
                      labelText: 'FirstName',
                      controller: firstname,
                      hintText: 'Enter first name',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Last Name',
                      controller: lastname,
                      hintText: 'Enter last name',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Province',
                      controller: province,
                      hintText: 'Enter Province',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'city/municipality',
                      controller: city,
                      hintText: 'Enter city/municipality',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Barangay',
                      controller: barangay,
                      hintText: 'Enter Barangay',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Zone/Block/Street',
                      controller: zone,
                      hintText: 'Enter Zone/Block/Street',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Zip Code',
                      controller: zipcode,
                      hintText: 'Enter zip code',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Email',
                      controller: emailController,
                      hintText: 'Enter email',
                      obscuretext: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Password',
                      controller: passController,
                      hintText: 'Enter Password',
                      obscuretext: obscurepassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10),
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
                    padding: const EdgeInsets.all(10),
                    child: MyTextField(
                      labelText: 'Confirm Password',
                      controller: confirmPassController,
                      hintText: 'Enter confirm Password',
                      obscuretext: obscurepassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10),
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
                          registerUser();
                        })),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 50),
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
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
