part of 'register_cubit.dart';

@immutable
abstract class RegisterState {
  User get user=>user;
}

class RegisterInitial extends RegisterState {}
class RegisterLoading extends RegisterState {}
class Registered extends RegisterState {
  User userModel;
  Registered(this.userModel);
  @override
  // TODO: implement user
  User get user => userModel;
}
class RegisterError extends RegisterState {
  String message;
  RegisterError(this.message);
}
