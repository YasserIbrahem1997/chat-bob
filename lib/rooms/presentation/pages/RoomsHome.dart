import 'package:bob_app/nav_bar/service/navBarNotifier.dart';
import 'package:bob_app/recharge/presentation/packages.dart';
import 'package:bob_app/rooms/bloc/room_cubit.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:bob_app/rooms/presentation/pages/roomScreen.dart';
import 'package:bob_app/search_screen/widgets/componants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'as UrlLauncher;

import '../../../appConstants/colors.dart';
import '../../../appConstants/widgets/loadingPage.dart';
import '../../../profile/presentation/account_screen.dart';
import '../../../sherdpref/sherdprefrance.dart';

class AddGroup extends StatelessWidget {
  AddGroup({Key? key}) : super(key: key);
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextEditingController roomController = TextEditingController();
    String userId = CacheHelper.getData(key: 'uid');
    RoomCubit roomCubit = BlocProvider.of<RoomCubit>(context, listen: false);
    NavBarNotifier navBarNotifier=Provider.of<NavBarNotifier>(context,listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    height: 200.0,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/profile_top.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 70,
                    left: 50,
                    child: Text(
                      'Rooms',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  SingleChildScrollView(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('rooms')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            List rooms = snapshot.data!.docs;
                            List myRooms = rooms
                                .where((element) =>
                                element.data()['members'].contains(userId))
                                .toList();
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BlocConsumer<RoomCubit, RoomState>(
                                listener: (context, state) {
                                  if (state is RoomError) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(state.message),
                                      backgroundColor: const Color.fromARGB(
                                          255, 128, 21, 110),
                                    ));
                                  } else if (state is RoomEntered) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => RoomScreen(
                                            roomModel: state.joinedRoom),
                                      ));
                                    });
                                  }
                                },
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 70,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: myRooms.length,
                                          itemBuilder: (context, index) {
                                            RoomModel room = RoomModel.fromJson(
                                                myRooms[index].data()
                                                as Map<String, dynamic>);

                                            return InkWell(onTap: (){
                                              roomCubit.enterRoom(context, room);
                                            },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CachedNetworkImage(
                                                    imageBuilder:
                                                        (context, imageProvider) {
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                            color: PrimaryColor,
                                                            image: DecorationImage(
                                                                image:
                                                                imageProvider,
                                                                fit:
                                                                BoxFit.cover),
                                                            shape:
                                                            BoxShape.circle),
                                                        width: 45,
                                                        height: 45,
                                                      );
                                                    },
                                                    imageUrl:
                                                    room.image.toString(),
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) {
                                                      return Container(
                                                        decoration:
                                                        const BoxDecoration(
                                                            color:
                                                            PrimaryColor,
                                                            shape: BoxShape
                                                                .circle),
                                                        width: 35,
                                                        height: 35,
                                                        child: const Icon(
                                                          Icons.group,
                                                          color: Colors.white,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(room.name.toString())
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const Divider(),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                          const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            RoomModel room = RoomModel.fromJson(
                                                snapshot.data!.docs[index]
                                                    .data()
                                                as Map<String, dynamic>);
                                            return Card(
                                                child: ListTile(
                                                  title: Text(room.name.toString()),
                                                  subtitle: Text(
                                                      room.seatNumber.toString()),
                                                  onTap: () {
                                                    roomCubit.enterRoom(
                                                        context, room);
                                                  },
                                                ));
                                          }),
                                    ],
                                  );
                                },
                              ),
                            );
                          } else {
                            return LoadingPage();
                          }
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: PrimaryColor,onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(alignment: Alignment.center,actionsAlignment: MainAxisAlignment.end,
                  title:const Text('create Room',style: TextStyle(color: PrimaryColor),textAlign: TextAlign.start),
                  content: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: roomController,decoration: InputDecoration(contentPadding:const  EdgeInsets.symmetric(horizontal: 5),hintText: 'Enter room name..',border: OutlineInputBorder(borderSide: const BorderSide(color: PrimaryColor),borderRadius: BorderRadius.circular(15))),
                      ),
                      const SizedBox(height: 8,),

                      Consumer<NavBarNotifier>(builder: (context, value, child) {
                        return ToggleButtons(fillColor: PrimaryColor,isSelected:value.selections,onPressed: (index) {
                          value.selectSeat(index);
                        },disabledColor: Colors.grey,selectedColor: PrimaryColor,selectedBorderColor: PrimaryColor,disabledBorderColor: Colors.grey,children:   [Text('3',style: TextStyle(color:value.seatIndex==0?Colors.white: Colors.black,fontSize: 16) ,),Text('6',style: TextStyle(color:value.seatIndex==1?Colors.white: Colors.black,fontSize: 16) ,),Text('9',style: TextStyle(color:value.seatIndex==2?Colors.white: Colors.black,fontSize: 16) ,),],);
                      },)
                    ],
                  ),
                  actions: [

                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:const  Text('Close',style: TextStyle(fontWeight: FontWeight.bold,color: PrimaryColor),)),
                    TextButton(
                        onPressed: () {
                          if (roomController.text.isNotEmpty) {
                            BlocProvider.of<RoomCubit>(context,
                                listen: false)
                                .createRoom(
                                context,
                                roomController.text.trim(),
                                navBarNotifier.getSeatNumber());
                            roomController.clear();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Create',style: TextStyle(fontWeight: FontWeight.bold,color: PrimaryColor),)),
                  ],
                );
              });
        });
      },child:const  Icon(Icons.add)),
    );
  }
}