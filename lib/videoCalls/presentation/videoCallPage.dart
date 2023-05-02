
import 'dart:io';

import 'package:bob_app/appConstants/widgets/loadingPage.dart';
import 'package:bob_app/chat/data/chatModel.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:bob_app/videoCalls/bloc/video_call_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../chat/bloc/messages_cubit.dart';
import '../../sherdpref/sherdprefrance.dart';

class VideoCallPage extends StatefulWidget {
  final String receiverId;
  final ChatModel chatModel;
  const VideoCallPage({required this.chatModel,required this.receiverId, Key? key}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final String _roomID = 'QuickStartRoom-1';

  int _previewViewID = -1;
  int _playViewID = -1;
  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  ZegoMediaPlayer? mediaPlayer;

  bool _isEngineActive = false;
  ZegoRoomState _roomState = ZegoRoomState.Disconnected;
  ZegoPublisherState _publisherState = ZegoPublisherState.NoPublish;
  ZegoPlayerState _playerState = ZegoPlayerState.NoPlay;

  TextEditingController _publishingStreamIDController =
  new TextEditingController();
  TextEditingController _playingStreamIDController =
  new TextEditingController();

  @override
  void initState() {
    super.initState();
    setZegoEventCallback();
    BlocProvider.of<VideoCallCubit>(context,listen: false).startVideoChat(widget.chatModel.id);
    initVideoCall();
  }

  @override
  void dispose() {
    ZegoExpressEngine.destroyEngine();
    clearZegoEventCallback();
    stopPreview();
    logoutRoom();
    destroyEngine();
    super.dispose();
  }

  String userId = CacheHelper.getData(key: 'uid');
  int appId = 79832802;
  String appSign =
      '654acd5741d4693dccfd76004cced01dee136162ecf9401c8b872380a257a5e7';
  ZegoScenario scenario = ZegoScenario.General;

  void createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(appId, scenario,
        enablePlatformView: false, appSign: appSign);
    if (kIsWeb) {
      profile.appSign = null; // Don't use appsign on web
    }
    ZegoExpressEngine.createEngineWithProfile(profile);

    setState(() => _isEngineActive = true);

  }

  initVideoCall() {
    String chatId = BlocProvider.of<MessagesCubit>(context, listen: false)
        .state
        .currentChat.id.toString();
    createEngine();
    loginRoom();
    startPublishingStream();

    BlocProvider.of<VideoCallCubit>(context, listen: false)
        .startVideoChat(chatId);
    startPreview();
    startPlayingStream();

  }

  // MARK: - Step 2: LoginRoom

  void loginRoom() {
    // Instantiate a ZegoUser object
    ZegoUser user = ZegoUser(userId, 'userName');

    if (kIsWeb) {
      ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
      config.token = 'mKv20kcHFHchYCZ72rrkoDf1iJp1';
      // Login Room WEB only supports token;
      ZegoExpressEngine.instance.loginRoom(_roomID, user, config: config);
    } else {
      // Login Room
      ZegoExpressEngine.instance.loginRoom(_roomID, user);
    }

  }

  void logoutRoom() {
    // Logout room will automatically stop publishing/playing stream.
    //
    // But directly logout room without destroying the [PlatformView]
    // or [TextureRenderer] may cause a memory leak.
    ZegoExpressEngine.instance.logoutRoom(_roomID);

    clearPreviewView();
    clearPlayView();
  }

  // MARK: - Step 3: StartPublishingStream
  void startPreview() {
    Future<void> _startPreview(int viewID) async {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      await ZegoExpressEngine.instance.startPreview(canvas: canvas);
    }

    if (Platform.isIOS || Platform.isAndroid || kIsWeb) {
      ZegoExpressEngine.instance.createCanvasView((viewID) {
        _startPreview(viewID);
      }).then((widget) {
        setState(() {
          _previewViewWidget = widget;
        });
      });
    } else {
      ZegoExpressEngine.instance.startPreview();
    }
  }

  void stopPreview() {
    if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb) return;

    if (_previewViewWidget == null) {
      return;
    }

    ZegoExpressEngine.instance.stopPreview();
    clearPreviewView();
  }

  void startPublishingStream() {
    ZegoExpressEngine.instance.startPublishingStream(userId);

  }

  void stopPublishingStream() {
    ZegoExpressEngine.instance.stopPublishingStream();
  }

  // MARK: - Step 4: StartPlayingStream
  void startPlayingStream() {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);

    }

    if (Platform.isIOS || Platform.isAndroid || kIsWeb) {

      ZegoExpressEngine.instance.createCanvasView((viewID) {
        _startPlayingStream(viewID, widget.receiverId);
      }).then((widget) {
        setState(() {
          _playViewWidget = widget;
        });
      });
    } else {
      ZegoExpressEngine.instance.startPlayingStream(widget.receiverId);
    }
  }

  void stopPlayingStream(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);

    clearPlayView();
  }

  // MARK: - Exit

  void destroyEngine() async {
    stopPreview();
    clearPreviewView();
    clearPlayView();


    ZegoExpressEngine.destroyEngine()
        .then((ret) => print('already destroy engine'));



    // Notify View that engine state changed
    // setState(() {
    //   _isEngineActive = false;
    //   _roomState = ZegoRoomState.Disconnected;
    //   _publisherState = ZegoPublisherState.NoPublish;
    //   _playerState = ZegoPlayerState.NoPlay;
    // });
  }

  // MARK: - Zego Event

  void setZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {

      setState(() => _roomState = state);
    };

    ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
        ZegoPublisherState state,
        int errorCode,
        Map<String, dynamic> extendedData) {

      setState(() => _publisherState = state);
    };

    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      print(
          '🚩 📥 Player state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      setState(() => _playerState = state);
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
          stopPlayingStream(_playingStreamIDController.text.trim());
        }
      });
    });
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  void clearPreviewView() {
    if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb) return;

    if (_previewViewWidget == null) {
      return;
    }

    // Developers should destroy the [CanvasView] after
    // [stopPublishingStream] or [stopPreview] to release resource and avoid memory leaks
    ZegoExpressEngine.instance.destroyCanvasView(_previewViewID);
    setState(() => _previewViewWidget = null);
  }

  void clearPlayView() {
    if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb) return;

    if (_playViewWidget == null) {
      return;
    }
    ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
    setState(() => _playViewWidget = null);
  }

  Widget singleView(chatId) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _previewViewWidget,
        ),

        endCallButton(chatId)
      ],
    );
  }

  Widget videoCallView(chatId) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _playViewWidget,
        ),
        Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: 200,
              height: 200,
              child: _previewViewWidget,
            )),
        endCallButton(chatId)
      ],
    );
  }

  Widget endCallButton(chatId) {
    VideoCallCubit videoCallCubit=BlocProvider.of<VideoCallCubit>(context,listen: false);

    return Positioned.fill(
        bottom: 70,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 70,child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                CircleAvatar(minRadius: 25,maxRadius: 25,backgroundColor: Colors.grey,child:  IconButton(onPressed: () {
                  videoCallCubit.enableCamera(videoCallCubit.isCamerafront);
                }, icon:const  Icon(Icons.mic_off,color: Colors.white,)),),
                CircleAvatar(maxRadius: 25,minRadius: 25,backgroundColor: Colors.grey,child:  IconButton(onPressed: () {
                  videoCallCubit.useFrontCamera(videoCallCubit.isCameraEnable);
                }, icon: const Icon(Icons.volume_up,color: Colors.white,)),)
              ],)),
              InkWell(
                onTap: () {
                  logoutRoom();
                  destroyEngine();
                  BlocProvider.of<VideoCallCubit>(context, listen: false)
                      .leaveVideoChat(chatId);
                  Navigator.pop(context);
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.red,
                  maxRadius: 35,
                  minRadius: 30,
                  child: Icon(Icons.call_end, size: 30, color: Colors.white),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
            child: GestureDetector(
              child: mainContent(),
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            )),
      ),
      onWillPop: () async {
        logoutRoom();
        destroyEngine();
        BlocProvider.of<VideoCallCubit>(context, listen: false)
            .leaveVideoChat(widget.chatModel.id);
        return true;
      },
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Column(children: [
          BlocConsumer<VideoCallCubit, VideoCallState>(
            listener: (context, state) {
              if (state is VideoJoined) {
                startPreview();
                startPlayingStream();
              }
            },
            builder: (context, state) {
              if (state is VideoLoading) {
                return const LoadingPage();
              } else {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatModel.id)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!['videoRoom'].length > 1) {
                        return videoCallView(widget.chatModel.id);
                      } else {
                        return singleView(widget.chatModel.id);
                      }
                    } else {
                      return const LoadingPage();
                    }
                  },
                );
              }
            },
          ),
        ]));
  }
}