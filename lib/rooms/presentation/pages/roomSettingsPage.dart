import 'package:bob_app/appConstants/colors.dart';
import 'package:bob_app/rooms/bloc/room_cubit.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../search_screen/widgets/componants.dart';
import '../../../sherdpref/sherdprefrance.dart';

class RoomSettingsScreen extends StatelessWidget {
  final RoomModel roomModel;

  const RoomSettingsScreen({required this.roomModel, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    RoomCubit roomCubit=BlocProvider.of<RoomCubit>(context,listen: false);
    String userId=CacheHelper.getData(key: 'uid');
    return Scaffold(
      appBar: AppBar(
        title: Text(roomModel.name.toString()),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(roomModel.roomId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  RoomModel room = RoomModel.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(onTap: (){
                        roomCubit.pickRoomImage(userId, false, room);

                      },
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,imageBuilder: (context, imageProvider) {
                            return     Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            );
                          },
                            imageUrl: room.image.toString(),
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Icons.group,
                                color: Colors.white,
                              );
                            },
                          )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            room.name.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () {
                                textController.text=room.name.toString();
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(title: const Text('Change Room Name'), content: TextField(controller: textController,),actions: [
                                    TextButton(onPressed: () {
                                      textController.clear();

                                      Navigator.pop(context);
                                    }, child:const  Text('Cancel')),

                                    TextButton(onPressed: () {
                                      if(textController.text.isNotEmpty){
                                        roomCubit.changeName(room, textController.text.trim());
                                        textController.clear();
                                        Navigator.pop(context);
                                      }
                                    }, child:const  Text('Ok')),
                                  ],);
                                },);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ))
                        ],
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Text('Room background:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 14)),
                          const SizedBox(
                            width: 7,
                          ),
                          CachedNetworkImage(
                            fit: BoxFit.cover,imageBuilder: (context, imageProvider) {
                            return     Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                boxShadow: [BoxShadow(color: PrimaryColor,blurRadius: 2)],
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            );
                          },
                            imageUrl: room.backGround.toString(),
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Icons.group,
                                color: Colors.white,
                              );
                            },
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          IconButton(
                              onPressed: () {
                                roomCubit.pickRoomImage(userId, true, room);
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                              )),
                          IconButton(onPressed: (){
                            roomCubit.removeRoomBackGround(room.roomId);
                          }, icon:const  Icon(Icons.delete_outline,color: PrimaryColor,))
                        ],
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Text('Room Chat:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 14)),
                          const SizedBox(
                            width: 8,
                          ),
                          Switch(value: room.chatEnabled!,activeColor: PrimaryColor, onChanged: (value) {
                            roomCubit.toggleChat(room);

                          },)
                        ],
                      ),

                      const Divider(),
                      const SizedBox(
                        height: 15,
                      ),

                      Row(
                        children: [
                          const Text('Announcement',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 14)),
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(onPressed: () {
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(title: const Text('Add new announcement'), content: TextField(controller: textController,),actions: [
                                TextButton(onPressed: () {
                                  Navigator.pop(context);


                                }, child:const  Text('Cancel')),

                                TextButton(onPressed: () {
                                  if(textController.text.isNotEmpty){
                                    roomCubit.sendAnnouncement(room, textController.text.trim());
                                    textController.clear();
                                    Navigator.pop(context);
                                  }
                                }, child:const  Text('Ok')),
                              ],);
                            },);
                          }, icon:  Icon(Icons.add_box_outlined,color: PrimaryColor,))
                        ],
                      ),

                      const Divider(),
                      const SizedBox(
                        height: 15,
                      ),

                      Row(
                        children: [
                          Text('Room description: ${room.description}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 14)),
                          const SizedBox(
                            width: 8,
                          ),
                          IconButton(onPressed: () {
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(title: const Text('Add new announcement'), content: TextField(controller: textController,),actions: [
                                TextButton(onPressed: () {
                                  Navigator.pop(context);


                                }, child:const  Text('Cancel')),

                                TextButton(onPressed: () {
                                  if(textController.text.isNotEmpty){
                                    roomCubit.changeDescription(room.roomId, textController.text.trim());
                                    textController.clear();
                                    Navigator.pop(context);
                                  }
                                }, child:const  Text('Ok')),
                              ],);
                            },);
                          }, icon:  Icon(Icons.edit,color: PrimaryColor,))
                        ],
                      ),

                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )),
      ),
    );
  }
}