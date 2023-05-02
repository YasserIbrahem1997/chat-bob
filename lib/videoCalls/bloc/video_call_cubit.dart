import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../sherdpref/sherdprefrance.dart';

part 'video_call_state.dart';

class VideoCallCubit extends Cubit<VideoCallState> {
  VideoCallCubit() : super(VideoCallInitial());
  final firebase = FirebaseFirestore.instance;

  startVideoChat(chatId) {
    emit(VideoLoading());
    try {
      String userId = CacheHelper.getData(key: 'uid');
      firebase.collection('chats').doc(chatId).update({
        'videoRoom': FieldValue.arrayUnion([userId])
      }).then((value) {
        emit(VideoJoined());
      }).onError((error, stackTrace) {
        emit(VideoError(error.toString()));
      });
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }

  leaveVideoChat(chatId) {
    try {
      String userId = CacheHelper.getData(key: 'uid');
      firebase.collection('chats').doc(chatId).update({
        'videoRoom': FieldValue.arrayRemove([userId])
      }).then((value) {
        emit(VideoLeft());
      }).onError((error, stackTrace) {
        emit(VideoError(error.toString()));
      });
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }

  bool isCameraEnable = true;

  void isCamera() {
    isCameraEnable != isCameraEnable;
    emit(IsCamera());
  }

  bool isCamerafront = true;

  void isCameraFro() {
    isCamerafront != isCamerafront;
    emit(IsCamerafront());
  }

  Future<void> useFrontCamera(bool enable,
      {ZegoPublishChannel? channel}) async {
    return await ZegoExpressEngine.instance
        .useFrontCamera(enable, channel: channel);
  }

  Future<void> enableCamera(bool enable, {ZegoPublishChannel? channel}) async {
    return await ZegoExpressEngine.instance
        .enableCamera(enable, channel: channel);
  }
}

