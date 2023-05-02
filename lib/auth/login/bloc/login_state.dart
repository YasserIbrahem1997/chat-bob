part of 'login_cubit.dart';

abstract class LoginState {
  UserModel get user => user;
  String get code=>'';
  String get phoneNumber=>'';
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}


class CodeReceived extends LoginState{
  String myCode;
  String number;
  CodeReceived(this.myCode,this.number);
  @override
  // TODO: implement code
  String get code => myCode;
  String get phoneNumber => number;

}
class LoggedIn extends LoginState {
  UserModel userModel;
  String number;
  LoggedIn(this.userModel,this.number);

  @override
  UserModel get user => userModel;

  @override
  // TODO: implement phoneNumber
  String get phoneNumber => number;


}

class LoginError extends LoginState {
  String message;
  LoginError(this.message);
}

class LoginChangePasswordState extends LoginState {}

//=============================================

class PhoneAuthInitial extends LoginState {}

class Loading extends LoginState {}

class ErrorOccurred extends LoginState {
  final String errorMsg;

  ErrorOccurred({required this.errorMsg});
}

class PhoneNumberSubmited extends LoginState {}

class PhoneOTPVerified extends LoginState {}