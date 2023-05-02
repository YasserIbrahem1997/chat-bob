import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../sherdpref/sherdprefrance.dart';

part 'voice_call_state.dart';

class VoiceCallCubit extends Cubit<VoiceCallState> {
  VoiceCallCubit() : super(VoiceCallInitial());
  static VoiceCallCubit get(context) => BlocProvider.of(context);
  final firebase = FirebaseFirestore.instance;

  startVoiceChat(chatId) {
    emit(VoiceLoading());
    try {
      String userId = CacheHelper.getData(key: 'uid');
      firebase.collection('chats').doc(chatId).update({
        'voiceRoom': FieldValue.arrayUnion([userId])
      }).then((value) {
        emit(VoiceJoined());
      }).onError((error, stackTrace) {
        emit(VoiceError(error.toString()));
      });
    } catch (e) {
      emit(VoiceError(e.toString()));
    }
  }

  leaveVoiceChat(chatId) {
    try {
      String userId = CacheHelper.getData(key: 'uid');
      firebase.collection('chats').doc(chatId).update({
        'voiceRoom': FieldValue.arrayRemove([userId])
      }).then((value) {
        emit(VoiceLeft());
      }).onError((error, stackTrace) {
        emit(VoiceError(error.toString()));
      });
    } catch (e) {
      emit(VoiceError(e.toString()));
    }
  }

  Future<void> toggleMicrophone() async {
try{
  bool mute = await ZegoExpressEngine.instance.isMicrophoneMuted();
  return await ZegoExpressEngine.instance.muteMicrophone(mute);
}catch(e){
  print(e.toString());
    bool mute = await ZegoExpressEngine.instance.isMicrophoneMuted();
    return await ZegoExpressEngine.instance.muteMicrophone(mute);
  }


  }

  Future<void> toggleSpeaker() async {
    bool mute= await ZegoExpressEngine.instance.isSpeakerMuted();
    return await ZegoExpressEngine.instance.muteSpeaker(mute);
  }


}