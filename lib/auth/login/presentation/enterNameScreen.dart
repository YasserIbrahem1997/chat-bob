import 'package:bob_app/auth/login/bloc/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../nav_bar/nav_bar.dart';
import '../../../profile/presentation/account_screen.dart';

class EnterNameScreen extends StatelessWidget {
  final String number;
  const EnterNameScreen({required this.number,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoginCubit loginCubit=BlocProvider.of<LoginCubit>(context,listen: false);
    TextEditingController nameController=TextEditingController();
    GlobalKey<FormState> formKey=GlobalKey();
    return Scaffold(body: Form(
      child: BlocConsumer<LoginCubit,LoginState>(listener: (context, state) {
        if(state is LoginError){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is LoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigateTo(context,const  BottomTapBar());
          });
        }
      },builder: (context, state) {
        return Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min,children: [
            TextFormField(controller: nameController,decoration:const  InputDecoration(border: OutlineInputBorder(),hintText: 'Enter your name here'),validator: (value) {
              value!=null&&value.isEmpty?'enter your name':null;
            },),
           const  SizedBox(height: 15,),
            ElevatedButton(onPressed: () {
              if(nameController.text.isNotEmpty){
            loginCubit.createProfile(number, nameController.text);
              }
            }, child: const Text('submit'))

          ]),
        );
      },)
    ),);
  }
}
