import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  register({required String email,required String password,required String name})async{
    try{
      emit(RegisterLoading());

      FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((value) {
        if(value.user!=null){
          emit(Registered(value.user!));
          FirebaseFirestore.instance.collection('users').doc(value.user!.uid).set({
            "name":name,
            "email":email,
            "userId":value.user!.uid,
            "image":'',
            'phone':"",
          });
        }else{
          emit(RegisterError('something went wrong!'));
        }
      }).catchError((e){
        print(e.toString());
        emit(RegisterError(e.toString()));
      });

    }catch(e){
      emit(RegisterError(e.toString()));
    }
  }
}
