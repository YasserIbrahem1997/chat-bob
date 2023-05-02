import 'dart:developer';

import 'package:bob_app/appConstants/widgets/loadingPage.dart';
import 'package:bob_app/chat/bloc/messages_cubit.dart';
import 'package:bob_app/chat/data/chatModel.dart';
import 'package:bob_app/chat/presentation/chatScreen.dart';
import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/profile/presentation/account_screen.dart';
import 'package:bob_app/search_screen/widgets/componants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../sherdpref/sherdprefrance.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId = CacheHelper.getData(key: 'uid');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 240, 236, 236),
        elevation: 0,
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text(
          'Bob',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>);
              return InkWell(
                onTap: () {
                  navigateTo(context, const AccountScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      user.image!.isNotEmpty
                          ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 15,
                        backgroundImage:
                        NetworkImage(user.image.toString()),
                      )
                          : const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.black,
                size: 19,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 9),
          SizedBox(
            height: 90,
            child: BlocConsumer<MessagesCubit, MessagesState>(
              listener: (context, state) {
                if(state is ChatFound){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(chatModel: state.chatModel, userModel: state.receiver),));
                }
              },
              builder: (context, state) {
                return onlineFriends(context);
              },
            ),
          ),
          const Divider(),
          recentChats(),
        ],
      ),
    );
  }
}