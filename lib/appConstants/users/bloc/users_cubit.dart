import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../../../profile/data/userModel.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());
var firebase=FirebaseFirestore.instance.collection('users');
getUsers(context,List<String> users)async{
  try{
    List<UserModel>userList=[];
    for(String id in users){
      DocumentSnapshot doc=await firebase.doc(id).get();
    print(doc.data());
      userList.add(UserModel.fromJson(doc.data() as Map<String,dynamic>));
    }

    emit(UsersFound(userList));
  }catch(e){
    emit(UsersError(e.toString()));
  }
}

}
