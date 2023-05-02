import 'package:bob_app/auth/login/bloc/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../../../nav_bar/nav_bar.dart';
import '../../../profile/presentation/account_screen.dart';

class OtpScreen extends StatefulWidget {
  OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  int otpCodeLength = 6;
  bool isLoadingButton = false;
  bool enableButton = false;
  String otpCode = "";

  onOtpCallBack(String otpCode, bool isAutofill) {
    setState(() {
      this.otpCode = otpCode;
      if (otpCode.length == otpCodeLength && isAutofill) {
        enableButton = false;
        isLoadingButton = true;
      } else if (otpCode.length == otpCodeLength && !isAutofill) {
        enableButton = true;
        isLoadingButton = false;
      } else {
        enableButton = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var cubit = LoginCubit().get(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {


      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Verify Your Email',
              style: TextStyle(color: Colors.black, fontSize: 19),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Center(
                    child: Image.asset(
                      'assets/images/splach.png',
                      height: 197,
                      width: 197,
                    ),
                  ),
                  const SizedBox(height: 30),
                  RichText(
                      textAlign: TextAlign.center,
                      text:  TextSpan(
                          text:
                          'please enter the 4-digit code sent to  ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: state.phoneNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              //textAlign: TextAlign.center,
                            ),
                          ])),
                  SizedBox(height: 20),
                  TextFieldPin(
                    textController: otpController,
                    codeLength: otpCodeLength,
                    alignment: MainAxisAlignment.center,
                    defaultBoxSize: 40.0,
                    margin: 5,
                    selectedBoxSize: 50.0,
                    textStyle:const TextStyle(fontSize: 22),
                    defaultDecoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    onChange: (code) {
                      onOtpCallBack(code, false);
                    },
                  ),
                  SizedBox(
                    width: 335,
                    height: 55,
                    child: defaultBottom("Verify", context, () {
                     if(otpController.text==state.code){
                       cubit.signIn(context,state.phoneNumber);
                     }else{
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('code is wrong')));
                     }
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget defaultBottom(String titel, context, onPressed) => Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 182, 180, 178),
      border: Border.all(color: const Color.fromARGB(255, 9, 9, 9)),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: MaterialButton(
      onPressed: onPressed,
      child: Text(
        titel,
        style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold),
      ),
    ),
  );
}
//please enter the 4-digit code sent to