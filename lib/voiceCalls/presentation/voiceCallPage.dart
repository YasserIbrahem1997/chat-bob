import 'dart:async';

import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:bob_app/voiceCalls/bloc/voice_call_cubit.dart';
import 'package:bob_app/zegoManager/zegoVoiceCubit/zego_voice_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../chat/bloc/messages_cubit.dart';

class VoiceCallScreen extends StatefulWidget {
  final UserModel receiver;
  final String chatId;
  const VoiceCallScreen({required this.chatId,required this.receiver,Key? key}) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  Widget? _previewViewWidget;
  Widget? _playViewWidget;
  late ZegoVoiceCubit zegoVoiceCubit;


  @override
  void initState(){
    super.initState();
    zegoVoiceCubit=BlocProvider.of<ZegoVoiceCubit>(context,listen: false);
    zegoVoiceCubit.setZegoEventCallback(widget.chatId);
    zegoVoiceCubit.initVoiceCall(context,widget.chatId);
    zegoVoiceCubit.startPublishingStream();
    zegoVoiceCubit.startPlayingStream(widget.receiver.userId);
  }




  Widget singleView(chatId){
    return Stack(
      children: [
        Container(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,child: _previewViewWidget,),
        endCallButton(chatId)
      ],
    );
  }



  Widget endCallButton(chatId){
    return Align(alignment: Alignment.bottomCenter,
      child: InkWell(onTap: (){
        zegoVoiceCubit.logoutRoom(widget.chatId);
        zegoVoiceCubit.destroyEngine();
        BlocProvider.of<VoiceCallCubit>(context,listen: false).leaveVoiceChat(chatId);
        Navigator.pop(context);

      }, child:const CircleAvatar(backgroundColor: Colors.red,maxRadius: 35,minRadius: 30,child: Icon(Icons.call_end,size: 30,color: Colors.white),),),
    );
  }


  @override
  Widget build(BuildContext context) {
    String chatId= BlocProvider.of<MessagesCubit>(context,
        listen: false)
        .state
        .currentChat.id.toString();
    late VoiceCallCubit voiceCallCubit=BlocProvider.of<VoiceCallCubit>(context,listen: false);
    return WillPopScope(onWillPop:()async{
      zegoVoiceCubit.logoutRoom(widget.chatId);
      zegoVoiceCubit.destroyEngine();
      voiceCallCubit.leaveVoiceChat(chatId);
      return true;

    } ,
      child: Scaffold(backgroundColor: Colors.white,
          body: Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
              const SizedBox(height: 80,),

              SizedBox(height: 80,child: Row(mainAxisSize:MainAxisSize.min ,children: [
                CircleAvatar(minRadius: 30,maxRadius: 30,backgroundImage: NetworkImage(widget.receiver.image.toString()),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(mainAxisSize: MainAxisSize.min,children: [
                    Text(widget.receiver.name.toString(),style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
                  ]),
                ),
              ],)),
              const  Spacer(),

              SizedBox(height: 70,child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                IconButton(onPressed: () {
                  voiceCallCubit.toggleMicrophone();
                }, icon:const  Icon(Icons.mic_off)),
                IconButton(onPressed: () {
                  voiceCallCubit.toggleSpeaker();
                }, icon: const Icon(Icons.volume_up))
              ],)),
              const SizedBox(height: 30,),
              endCallButton(chatId),
              const SizedBox(height: 40,)


            ],),
          )
      ),
    );
  }
}