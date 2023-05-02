import 'package:bob_app/appConstants/colors.dart';
import 'package:bob_app/chat/bloc/messages_cubit.dart';
import 'package:bob_app/chat/data/chatModel.dart';
import 'package:bob_app/chat/presentation/chatScreen.dart';
import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../appConstants/widgets/loadingPage.dart';
import '../../chat/presentation/chatScreen.dart';
import '../../profile/presentation/account_screen.dart';


Widget onlineFriends(context){
  return StreamBuilder(stream: FirebaseFirestore.instance.collection('users').snapshots(),builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
    if(snapshot.hasData){
      List users=snapshot.data!.docs;
      return ListView.separated(
        itemCount: users.length,

        padding: const EdgeInsets.only(left: 20),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index){
          UserModel user=UserModel.fromJson(users[index].data() as Map<String,dynamic>);
          return  InkWell(onTap: () {
            BlocProvider.of<MessagesCubit>(context,listen: false).checkChat(context, user, false);
          },child: storyItem(user));
        },
        separatorBuilder: ((context, index) => const SizedBox(width: 10)),
      );
    }else{
      return const SizedBox.shrink();
    }
  },);
}

Widget recentChats(){
  String userId = CacheHelper.getData(key: 'uid');

  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: userId)
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasData) {
        List chats = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          itemCount: chats.length,
          itemBuilder: (context, index) {
            ChatModel chat = ChatModel.fromJson(chats[index].data()as Map<String,dynamic>);
            return labelChat(chat, context);
          },
          separatorBuilder: ((context, index) => myDivider()),
        );
      } else {
        return const LoadingPage();
      }
    },
  );
}

Widget textForm(
    TextEditingController controller, String label, int borderRadius, TextInputType number) {
  return Container(
    decoration: const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(236, 237, 242, 1),
          blurRadius: 10,
          offset: Offset(1.2, 5),
        ),
      ],
    ),
    height: 70,
    width: 335,
    child: TextFormField(
      expands: true,
      maxLines: null,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.white,
            ),
          ),
          filled: true,
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              )),
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey)),
    ),
  );
}

Widget labelChat(ChatModel chatModel, context) {
  String userId = CacheHelper.getData(key: 'uid');

  return BlocConsumer<MessagesCubit, MessagesState>(
    listener: (context, state) {},
    builder: (context, state) {
      String receiverId =
      chatModel.members!.firstWhere((element) => element != userId);
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(receiverId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            UserModel userModel = UserModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);
            return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userModel: userModel,
                        chatModel: chatModel,
                      ),
                    ),
                  );
                },
                leading: userAvatar(userModel,false),
                title: Text(
                  userModel.name.toString(),
                  style: TextStyle(color: Color(0xff00D3C1)),
                ),
                subtitle: Text(chatModel.messages!.isNotEmpty?chatModel.messages!.last.message.toString():'Say hi to ${userModel.name}'),
                trailing: const Icon(
                  Icons.phone,
                  color: Colors.blue,
                  size: 20,
                ));
          } else {
            return SizedBox.shrink();
          }
        },
      );
    },
  );
}

Widget storyItem(UserModel user) {
  return Column(mainAxisSize: MainAxisSize.min, children: [
    userAvatar(user,false),
    Text(
      user.name.toString(),
      overflow: TextOverflow.ellipsis,
    ),
  ]);
}

Widget userAvatar(UserModel userModel,bool room) {
  return Stack(children: [
    CircleAvatar(
      backgroundColor: PrimaryColor,
      radius:room?15: 30,
      child: CachedNetworkImage(
        imageUrl: userModel.image.toString(),
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          return Icon(Icons.person,color: Colors.white,);
        },
      ),
    ),
    room?SizedBox.shrink() :Container(
      margin: const EdgeInsets.only(left: 50),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 4),
        borderRadius: BorderRadius.circular(50),
        color: Colors.green,
      ),
    ),
  ]);
}