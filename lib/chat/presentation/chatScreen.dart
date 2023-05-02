import 'package:bob_app/appConstants/widgets/loadingPage.dart';
import 'package:bob_app/chat/bloc/messages_cubit.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:bob_app/videoCalls/presentation/videoCallPage.dart';
import 'package:bob_app/voiceCalls/presentation/voiceCallPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../appConstants/colors.dart';
import '../../image_screen/image_screen.dart';
import '../../profile/data/userModel.dart';
import '../data/chatModel.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chatModel;
  final UserModel userModel;
  const ChatScreen({required this.chatModel,required this.userModel, Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    String chatId = widget.chatModel.id.toString();
    String userId = CacheHelper.getData(key: 'uid');
    ScrollController scrollController = ScrollController();
    TextEditingController messageController = TextEditingController();
    var cubit = MessagesCubit().get(context);
    Duration duration = Duration();
    Duration position = Duration();
    bool isPlaying = false;
    bool isLoading = false;
    bool isPause = false;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: PrimaryColor,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: CachedNetworkImage(
                    imageUrl: widget.userModel.image.toString(),
                    errorWidget: ((context, url, error) => const Icon(
                          Icons.person,
                          color: Colors.white,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(widget.userModel.name.toString()),
                ),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () async{
                   if(await Permission.camera.isGranted){
                     Navigator.of(context).push(MaterialPageRoute(
                       builder: (context) => VideoCallPage(chatModel: widget.chatModel,
                           receiverId: widget.userModel.userId.toString()),
                     ));
                   }else{
                     await Permission.camera.request();
                   }
                  },
                  icon: const Icon(Icons.video_call)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VoiceCallScreen(
                              receiver: widget.userModel,
                              chatId: chatId,
                            )));
                  },
                  icon: const Icon(Icons.call)),
            ]),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List messageList = snapshot.data['messages'];
              SchedulerBinding.instance.addPostFrameCallback((_) {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });
              return ListView.builder(
                  controller: scrollController,
                  itemCount: messageList.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    MessageModel message = MessageModel.fromJson(
                        messageList[index] as Map<String, dynamic>);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: message.isImage!
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 150,
                                right: 20,
                                top: 30,
                                bottom: 5,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ImageScreen(
                                              messageModel: message,
                                            ),
                                        fullscreenDialog: true),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: CachedNetworkImage(
                                    imageUrl: message.image.toString(),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    progressIndicatorBuilder:
                                        (context, url, progress) =>
                                            const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) {
                                      return Container(
                                        color: Colors.grey,
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : BubbleNormal(
                              text: message.message.toString(),
                              isSender: userId == message.sender.toString(),
                              color: userId == message.sender.toString()
                                  ? Colors.grey.withOpacity(.5)
                                  : Colors.blue,
                              textStyle: TextStyle(
                                  color: userId == message.sender.toString()
                                      ? Colors.black
                                      : Colors.black),
                            ),
                    );
                  });
            } else {
              return const LoadingPage();
            }
          },
        ),
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: 70,
            color: Colors.grey.shade200,
            child: Row(children: [
              IconButton(
                  onPressed: () {
                    cubit.getChatImage(
                      context: context,
                      receiverId: widget.userModel.userId,
                      chatId: chatId,
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 19,
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: messageController,
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Type your message here'),
                  ),
                ),
              ),
              // IconButton(
              //     onPressed: () {
              //       showModalBottomSheet(
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0),
              //         ),
              //         isScrollControlled: true,
              //         context: context,
              //         builder: (context) {
              //           MessageModel message;
              //           return SizedBox(
              //             height: 200,
              //             child: InkWell(
              //               onTap: () {},
              //               child: RecordingScreen(),
              //             ),
              //           );
              //         },
              //       );
              //     },
              //     icon: const Icon(Icons.record_voice_over_rounded)),
              IconButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      BlocProvider.of<MessagesCubit>(context, listen: false)
                          .sendMessage(
                              context,
                              messageController.text,
                              widget.userModel.userId.toString(),
                              chatId,
                              false,
                              false);

                      messageController.clear();
                    }
                  },
                  icon: const Icon(Icons.send)),
            ]),
          ),
        ));
  }

  Widget toggleMessage(MessageModel message, userId,
      {duration, isPlaying, isLoading, isPause, audioPlayer}) {
    if (message.isImage!) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 150,
          right: 20,
          top: 30,
          bottom: 5,
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImageScreen(
                        messageModel: message,
                      ),
                  fullscreenDialog: true),
            );
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 2,
            child: CachedNetworkImage(
              imageUrl: message.image.toString(),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              progressIndicatorBuilder: (context, url, progress) =>
                  const CircularProgressIndicator(),
              errorWidget: (context, url, error) {
                return Container(
                  color: Colors.grey,
                  child: const Icon(
                    Icons.error,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else if (message.isRecord!) {
      return BubbleNormalAudio(
        color: const Color(0xFFE8E8EE),
        duration: duration.inSeconds.toDouble(),
        position: duration.inSeconds.toDouble(),
        isPlaying: isPlaying,
        isLoading: isLoading,
        isPause: isPause,
        onSeekChanged: ((value) {}),
        onPlayPauseButtonClick: ((() async {
          await audioPlayer.play(message.message!);
        })),
        sent: true,
      );
    } else if (message.isVideo!) {
      return const SizedBox.shrink();
    } else {
      return BubbleNormal(
        text: message.message.toString(),
        isSender: userId == message.sender.toString(),
        color: userId == message.sender.toString()
            ? Colors.grey.withOpacity(.5)
            : Colors.blue,
        textStyle: TextStyle(
          color:
              userId == message.sender.toString() ? Colors.black : Colors.black,
        ),
      );
    }
  }
}
/**
 *
 *
 *
 * Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: message.isImage!
    ? Padding(
    padding: const EdgeInsets.only(
    left: 150,
    right: 20,
    top: 30,
    bottom: 5,
    ),
    child: GestureDetector(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => ImageScreen(
    messageModel: message,
    ),
    fullscreenDialog: true),
    );
    },
    child: Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10)),
    height: MediaQuery.of(context).size.height / 3,
    width: MediaQuery.of(context).size.width / 2,
    child: CachedNetworkImage(
    imageUrl: message.image.toString(),
    imageBuilder: (context, imageProvider) =>
    Container(
    decoration: BoxDecoration(
    image: DecorationImage(
    image: imageProvider,
    fit: BoxFit.cover,
    ),
    ),
    ),
    progressIndicatorBuilder:
    (context, url, progress) =>
    const CircularProgressIndicator(),
    errorWidget: (context, url, error) {
    return Container(
    color: Colors.grey,
    child: const Icon(
    Icons.error,
    color: Colors.white,
    ),
    );
    },
    ),
    ),
    ),
    )
    : BubbleNormal(
    text: message.message.toString(),
    isSender: userId == message.sender.toString(),
    color: userId == message.sender.toString()
    ? Colors.grey.withOpacity(.5)
    : Colors.blue,
    textStyle: TextStyle(
    color: userId == message.sender.toString()
    ? Colors.black
    : Colors.black),
    ),
    );
    }
 */