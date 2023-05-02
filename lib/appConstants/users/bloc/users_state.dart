part of 'users_cubit.dart';

@immutable
abstract class UsersState {
  List<UserModel>get userList=>[];
}

class UsersInitial extends UsersState {}
class UsersFound extends UsersState{
  final List<UserModel>users;
  UsersFound(this.users);

  @override
  // TODO: implement userList
  List<UserModel> get userList => users;

}
class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}
