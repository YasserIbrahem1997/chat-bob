import 'package:bob_app/auth/login/presentation/enterNameScreen.dart';
import 'package:bob_app/auth/login/presentation/otp.dart';
import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/profile/presentation/account_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../sherdpref/sherdprefrance.dart';
import 'Package:firebase_auth/firebase_auth.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  LoginCubit get(context) => BlocProvider.of(context);



  logout() {
    try {
      FirebaseAuth.instance.signOut();
      CacheHelper.removeData(key: 'uid');
      emit(LoginInitial());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  IconData suffix = Icons.visibility;
  bool isPassword = false;

  ChangePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility : Icons.visibility_off;
    emit(LoginChangePasswordState());
  }


   String verificationId='';


  codeSent(String code,String number){
    emit(CodeReceived(code,number));
  }

  Future<void> signIn(context,String number) async {
    try {

        FirebaseFirestore.instance
            .collection('users')
            .doc(number)
            .get()
            .then((value) async {
          if (value.exists) {
            CacheHelper.saveData(key: 'uid', value: number);
            emit(LoggedIn(
                UserModel.fromJson(value.data() as Map<String, dynamic>),number));
          } else {
WidgetsBinding.instance.addPostFrameCallback((_) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => EnterNameScreen(number: number,),));
});
          }
        });

      emit(PhoneOTPVerified());
    } catch (error) {
      emit(ErrorOccurred(errorMsg: error.toString()));
    }
  }

  createProfile(number,name)async{
    try{
      FirebaseFirestore.instance
          .collection('users')
          .doc(number)
          .set({
        "name": name,
        "email": '',
        "userId": number,
        "image": '',
        'phone': number,
      });
      await CacheHelper.saveData(
          key: 'uid',
          value: number);
      emit(LoggedIn(
          UserModel(email: '',image: '',name: '',phone: number,userId: number),number));

    }catch(e){emit(LoginError(e.toString()));}
  }
  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String? uid;
  String? phoneNumber;

  User getLoggedInUser() {
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    uid = firebaseUser.uid;
    phoneNumber = firebaseUser.phoneNumber;
    return firebaseUser;
  }
}