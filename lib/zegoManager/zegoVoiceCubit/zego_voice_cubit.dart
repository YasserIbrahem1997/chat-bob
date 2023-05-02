import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../chat/bloc/messages_cubit.dart';
import '../../sherdpref/sherdprefrance.dart';
import '../../videoCalls/bloc/video_call_cubit.dart';
import '../../voiceCalls/bloc/voice_call_cubit.dart';

part 'zego_voice_state.dart';

class ZegoVoiceCubit extends Cubit<ZegoVoiceState> {
  ZegoVoiceCubit() : super(ZegoVoiceInitial());
  String userId=CacheHelper.getData(key: 'uid');
  int appId=79832802;
  String appSign='654acd5741d4693dccfd76004cced01dee136162ecf9401c8b872380a257a5e7';
  ZegoScenario scenario=ZegoScenario.General;

  int previewViewID = -1;
  int playViewID = -1;


  Widget previewViewWidget=SizedBox();
  Widget playViewWidget=SizedBox();

  ZegoMediaPlayer? mediaPlayer;

  initVoiceCall(context,roomId){
    String chatId= BlocProvider.of<MessagesCubit>(context,
        listen: false)
        .state
        .currentChat.id.toString();
    //Create engine
    createEngine();
    //LoginRoom
    loginRoom(roomId);
    //start publishing

    BlocProvider.of<VoiceCallCubit>(context,listen: false).startVoiceChat(chatId);


    // startPlayingStream(widget.receiverId);

  }
  void createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(
        appId,scenario,
        enablePlatformView: false,
        appSign: appSign);

    ZegoExpressEngine.createEngineWithProfile(profile);

  }

  void loginRoom(roomId) {
    ZegoUser user = ZegoUser(
        userId,
        'userName');

    if (kIsWeb) {
      ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
      config.token ='mKv20kcHFHchYCZ72rrkoDf1iJp1';
      ZegoExpressEngine.instance.loginRoom(roomId, user, config: config);
    } else {
      // Login Room
      ZegoExpressEngine.instance.loginRoom(roomId, user);
    }

  }

  void logoutRoom(roomId) {

    ZegoExpressEngine.instance.logoutRoom(roomId);

  }




  void startPublishingStream() {
    ZegoExpressEngine.instance.startPublishingStream(userId);
  }

  void stopPublishingStream() {
    ZegoExpressEngine.instance.stopPublishingStream();
  }

  void startPlayingStream(receiverId) {
    ZegoExpressEngine.instance.startPlayingStream(receiverId);

  }

  void stopPlayingStream(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);

  }


  void destroyEngine() async {

    ZegoExpressEngine.destroyEngine();

  }

  // MARK: - Zego Event

  void setZegoEventCallback(receiverId) {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {

    };

    ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
        ZegoPublisherState state,
        int errorCode,
        Map<String, dynamic> extendedData) {

    };

    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {

    };

    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
      userList.forEach((e) {
        var userID = e.userID;
        var userName = e.userName;

      });
    };

    ZegoExpressEngine.onRoomStreamUpdate =
    ((roomID, updateType, streamList, extendedData) {
      streamList.forEach((stream) {
        var streamID = stream.streamID;


        if (updateType == ZegoPlayerState.NoPlay) {
          stopPlayingStream(receiverId);
        }
      });
    });
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }


  void clearPlayView() {
    if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb) return;

    if (playViewWidget == SizedBox()) {
      return;
    }


    ZegoExpressEngine.instance.destroyCanvasView(playViewID);
playViewWidget = SizedBox();
    emit(PreviewSet(previewViewWidget,playViewWidget));

  }


}
