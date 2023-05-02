import 'dart:developer';

import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/profile/presentation/account_screen.dart';
import 'package:bob_app/profile/presentation/widgets/userDetails.dart';
import 'package:bob_app/rooms/bloc/room_cubit.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:bob_app/rooms/presentation/widgets/speakerRequests.dart';
import 'package:bob_app/rooms/service/roomUserType.dart';
import 'package:bob_app/search_screen/widgets/componants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../appConstants/colors.dart';
import '../../../chat/data/chatModel.dart';
import '../../../sherdpref/sherdprefrance.dart';
import '../pages/roomSettingsPage.dart';

Widget roomDetails(context, RoomModel roomModel) {
  RoomCubit roomCubit = BlocProvider.of<RoomCubit>(context, listen: false);
  String userId = CacheHelper.getData(key: 'uid');
  return DefaultTabController(
    length: 2,
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:const  BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          boxShadow: [
            BoxShadow(color: PrimaryColor, blurRadius: 3, spreadRadius: 3)
          ]),
      height: MediaQuery.of(context).size.height / 1.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: PrimaryColor, blurRadius: 2)]),
                width: 70,
                height: 70,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: roomModel.image.toString(),
                  errorWidget: (context, url, error) {
                    return Icon(
                      Icons.group,
                      color: PrimaryColor,
                    );
                  },
                ),
              ),
            ),
            Text(
              roomModel.name.toString(),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              TabBar(
                  indicatorColor: PrimaryColor,labelColor: Colors.black,unselectedLabelColor: Colors.grey,
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                  labelStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                  tabs: [
                    const Tab(
                      text: 'Information',
                    ),
                    Tab(
                      text: 'Members ${roomModel.members!.length.toString()}',
                    )
                  ]),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.3,
                child: TabBarView(children: [
                  roomInfo(context, roomModel, roomCubit, userId),
                  roomMembersList(roomModel, userId, roomCubit)
                ]),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

Widget roomInfo(context, RoomModel roomModel, RoomCubit roomCubit, userId) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(
        height: 5,
      ),
      const Text('~ Room Owner ~',
          style: TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
      Card(
          shadowColor: PrimaryColor,
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 5,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(roomModel.owner)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      UserModel userModel = UserModel.fromJson(
                          snapshot.data!.data() as Map<String, dynamic>);
                      return Row(
                        children: [
                          userAvatar(userModel, true),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            userModel.name.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                // Spacer(),
              ],
            ),
          )),
     const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const  Text('Room description:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey)),
                const SizedBox(
                  height: 5,
                ),
                Text('\"${roomModel.description}\"',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      const Spacer(),
      Row(
        children: [
          IconButton(onPressed: (){
            Navigator.pop(context);
            navigateTo(context,   RoomSettingsScreen(roomModel: roomModel,));
          }, icon:const Icon(Icons.settings,color: Colors.black,)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: ElevatedButton(
                  style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                      side: MaterialStateProperty.all<BorderSide>(
                          const  BorderSide(color: PrimaryColor)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          roomModel.members!.contains(userId)
                              ? Colors.white
                              : PrimaryColor)),
                  onPressed: () {
                    roomModel.members!.contains(userId)
                        ? roomCubit.exitRoom(roomModel)
                        : roomCubit.joinRoom(roomModel);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: roomModel.members!.contains(userId)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:const [
                               Icon(
                                Icons.person_outline,
                                color: PrimaryColor,
                              ),
                              Text(
                                'Joined',
                                style: TextStyle(color: PrimaryColor, fontSize: 14),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                'Join',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              )
                            ],
                          ),
                  )),
            ),
          ),
        ],
      )
    ],
  );
}

Widget roomMembersList(RoomModel roomModel, userId, RoomCubit roomCubit) {
  return ListView.builder(
    itemCount: roomModel.members!.length,
    itemBuilder: (context, index) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(roomModel.members![index])
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            UserModel user = UserModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);
            return roomMemberItem(context, user, userId, roomModel, roomCubit);
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    },
  );
}



Widget RequestsButton(context) {
  return IconButton(
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: const SpeakerRequests()),
              );
            },
          );
        });
      },
      icon: Icon(
        Icons.queue,
        color: PrimaryColor,
      ));
}


Widget RoomListenersList(context, roomId, UserTypes userType) {
  RoomCubit roomCubit = BlocProvider.of<RoomCubit>(context, listen: false);
  String userId = CacheHelper.getData(key: 'uid');

  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomId)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              RoomModel room = RoomModel.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: room.listeners!.length,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(room.listeners![index])
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        UserModel user = UserModel.fromJson(
                            snapshot.data!.data() as Map<String, dynamic>);
                        return roomMemberItem(
                            context, user, userId, room, roomCubit);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              );
            } else {
              return SizedBox.shrink();
            }
          },
        )
      ],
    ),
  );
}


Widget roomMemberItem(
    context, UserModel user, userId, RoomModel room, RoomCubit roomCubit) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: ListTile(
        leading: userAvatar(user, true),
        title: Text(user.name.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              color: memberTypeColor(context, user.userId, room),
              size: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            // if(user.userId!=roomModel.owner&&!roomModel.admins!.contains(user.userId))
            if (userId == room.owner || room.admins!.contains(userId))
              if (roleAuthorization(room, user.userId))
                IconButton(
                  onPressed: () async {

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          alignment: Alignment.center,
                          actionsAlignment: MainAxisAlignment.center,
                          content: Text('Take action with ${user.name}',
                              textAlign: TextAlign.center),
                          actions: [
                            if (room.owner == userId)
                              TextButton(
                                  onPressed: () {
                                    if (room.admins!.contains(user.userId)) {
                                      roomCubit.removeAdmin(
                                          user.userId.toString(),
                                          room.roomId.toString());
                                      Navigator.pop(context);
                                    } else {
                                      roomCubit.makeAdmin(
                                          user.userId.toString(),
                                          room.roomId.toString());
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(room.admins!.contains(user.userId)
                                      ? "Remove admin"
                                      : 'Make admin')),
                            TextButton(
                                onPressed: () {
                                  roomCubit.kickFromRoom(
                                      user.userId.toString(),
                                      roomCubit.state.currentRoom.roomId
                                          .toString());
                                  Navigator.pop(context);
                                },
                                child: const Text('Kick from room')),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
          ],
        )),
  );
}


MaterialColor memberTypeColor(context, memberId, RoomModel roomModel) {
  if (roomModel.owner == memberId) {
    return Colors.amber;
  } else if (roomModel.admins!.contains(memberId)) {
    return Colors.blue;
  } else {
    return Colors.grey;
  }
}


Widget roomTextField(context, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        hintText: 'Say Hi...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(horizontal: 5)),
  );
}


Widget roomChat(
    List<MessageModel> messages, ScrollController scrollController) {
  return SingleChildScrollView(
    controller: scrollController,
    child: ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        MessageModel message = messages[index];
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(message.sender.toString())
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>);
              SchedulerBinding.instance.addPostFrameCallback((_) {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });
              return InkWell(onTap: (){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showModalBottomSheet(backgroundColor: Colors.transparent,context: context,isScrollControlled: true,builder: (context) {
                    return userDetails(context,user);
                  },);
                });
              },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: userAvatar(user, true),
                              ),
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(message.message.toString()),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        );
      },
    ),
  );
}


roleAuthorization(RoomModel room, memberId) {
  String userId = CacheHelper.getData(key: 'uid');

  if (room.owner == memberId) {
    return false;
  } else if (room.admins!.contains(memberId)) {
    if (userId == room.owner) {
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}
