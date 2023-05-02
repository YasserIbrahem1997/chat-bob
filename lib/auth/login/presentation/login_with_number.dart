import 'dart:convert';
import 'dart:math';

import 'package:bob_app/auth/login/bloc/login_cubit.dart';
import 'package:bob_app/auth/login/presentation/otp.dart';
import 'package:bob_app/profile/presentation/account_screen.dart';
import 'package:bob_app/profile/presentation/widgets/profileWidgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import '../../../search_screen/widgets/componants.dart';

class LoginWithNumber extends StatelessWidget {
  const LoginWithNumber({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    var formKey = GlobalKey<FormState>();

    var cubit = LoginCubit().get(context);
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'login',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 29, vertical: 38),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/splach.png',
                      width: 104.59,
                      height: 139.2,
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    const Text(
                      'Welcom To Bob App',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    textForm(phoneController, 'Phone Number', 10,
                        TextInputType.number),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async{
                        var rng = new Random();
                        var code = rng.nextInt(900000) + 100000;
                        String baseUrl='https://smsmisr.com/api/v2/?';

                        var res=await http.post(Uri.parse(baseUrl),body: {
                          "Username":"LUzwnRLx",
                          "password":"so8ctbXj9s",
                          "language":"2",
                          "sender":"Codinga",
                          "Mobile":phoneController.text,
                          "message":"your OTP is $code"
                        });
                        if(res.statusCode==200){
                          print(res.body);
                          cubit.codeSent(code.toString(),phoneController.text);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OtpScreen(),));
                        });}
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(280, 47),
                          primary: const Color.fromARGB(255, 223, 221, 226),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text(
                        'login',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
