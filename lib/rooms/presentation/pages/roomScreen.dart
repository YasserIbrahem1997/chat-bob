import 'package:bob_app/appConstants/widgets/loadingPage.dart';
import 'package:bob_app/chat/bloc/messages_cubit.dart';
import 'package:bob_app/rooms/bloc/room_cubit.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:bob_app/rooms/presentation/widgets/roomWidgets.dart';
import 'package:bob_app/rooms/presentation/widgets/speakerRequests.dart';
import 'package:bob_app/rooms/service/roomUserType.dart';
import 'package:bob_app/zegoManager/zegoVoiceCubit/zego_voice_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../appConstants/colors.dart';
import '../../../profile/data/userModel.dart';
import '../../../sherdpref/sherdprefrance.dart';

class RoomScreen extends StatefulWidget {
   final RoomModel roomModel;

  const RoomScreen({Key? key, required this.roomModel}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late ZegoVoiceCubit zegoVoiceCubit;

  @override
  void initState() {
    zegoVoiceCubit = BlocProvider.of<ZegoVoiceCubit>(context, listen: false);
    zegoVoiceCubit.initVoiceCall(context, widget.roomModel.roomId);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    zegoVoiceCubit.destroyEngine();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userId = CacheHelper.getData(key: 'uid');
    RoomCubit roomCubit = BlocProvider.of<RoomCubit>(context, listen: false);
    MessagesCubit messagesCubit =
        BlocProvider.of<MessagesCubit>(context, listen: false);
    TextEditingController messageController = TextEditingController();
    ScrollController scrollController = ScrollController();
    return WillPopScope(
        onWillPop: () async {
          zegoVoiceCubit.logoutRoom(widget.roomModel.roomId);
          zegoVoiceCubit.destroyEngine();
          roomCubit.leaveRoom(context, userId, widget.roomModel.roomId);
          return true;
        },
        child: StreamBuilder(stream:FirebaseFirestore.instance.collection('rooms').doc(widget.roomModel.roomId).snapshots() ,builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasData){
            RoomModel roomModel=RoomModel.fromJson(snapshot.data!.data() as Map<String,dynamic>);
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title:InkWell(onTap: (){
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showModalBottomSheet(context: context,isScrollControlled: true,builder: (context) {
                        return roomDetails(context,roomModel);
                      },);
                    });
                  },
                    child: Container(width: MediaQuery.of(context).size.width/2,
                      decoration: BoxDecoration(borderRadius:const BorderRadius.all(Radius.circular(20)),  color: Colors.grey.withOpacity(.3)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(width: 5,),
                        CachedNetworkImage(
                          fit: BoxFit.cover,imageBuilder: (context, imageProvider) {
                          return     Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          );
                        },
                          imageUrl: roomModel.image.toString(),
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Icons.group,
                              color: Colors.white,
                            );
                          },
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(roomModel.name.toString(),
                                style: const TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${roomModel.members!.length} Members",
                                style: const TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.normal, fontSize: 14)),
                          ],
                        ),
                        if(!roomModel.members!.contains(userId))
                          Padding(
                            padding: const EdgeInsets.only(left: 7.0),
                            child: SizedBox(
                              width: 50,
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {
                                  roomModel.members!.contains(userId)?roomCubit.exitRoom(widget.roomModel)  :roomCubit.joinRoom(widget.roomModel);

                                },
                                style: ButtonStyle(alignment: Alignment.center,
                                    backgroundColor:
                                    MaterialStateProperty.all( PrimaryColor),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                child:const  Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        // Container(color: Colors.cyan,child: IconButton(onPressed: (){}, icon: const Icon(Icons.add,color: Colors.white,)),)
                      ]),
                    ),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return RoomListenersList(
                                    context,
                                    widget.roomModel.roomId.toString(),
                                    roomCubit.state.userType);
                              },
                            );
                          });
                        },
                        icon:  Icon(
                          Icons.person,
                          color:PrimaryColor,
                        )),
                    IconButton(
                        onPressed: () {
                          zegoVoiceCubit.logoutRoom(widget.roomModel.roomId);
                          zegoVoiceCubit.destroyEngine();
                          roomCubit.leaveRoom(context, userId, widget.roomModel.roomId);
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ))
                  ]),
              body:  Stack(children: [
                CachedNetworkImage(
                  fit: BoxFit.cover,imageBuilder: (context, imageProvider) {
                  return     Container(
                    width:MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  );
                },
                  imageUrl: roomModel.backGround.toString(),
                  errorWidget: (context, url, error) {
                    return Container(color: Colors.white, width:MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,);
                  },
                ),
                BlocConsumer<RoomCubit, RoomState>(
                  listener: (context, state) {
                    if (state is RoomUpdated) {
                      roomCubit.runStreams(context);
                    } else if (state is Kickedout) {
                      zegoVoiceCubit.logoutRoom(widget.roomModel.roomId);
                      zegoVoiceCubit.destroyEngine();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  builder: (context, state) {

                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child:      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                              itemCount: roomModel.seats!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4),
                              itemBuilder: (context, index) {
                                Seat? seat;
                                seat = roomModel.seats!.contains(roomModel
                                    .seats!
                                    .where((element) =>
                                element.seat == index)
                                    .isNotEmpty
                                    ? roomModel.seats!.firstWhere(
                                        (element) => element.seat == index)
                                    : Seat())
                                    ? roomModel.seats!.firstWhere(
                                        (element) => element.seat == index)
                                    : null;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  roomCubit.checkSeats(context, roomModel.seats,
                                      roomModel.listeners!.toList(), roomModel);
                                });
                                if (seat != null) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (roomCubit
                                                      .state.userType ==
                                                      UserTypes.owner ||
                                                      roomCubit
                                                          .state.userType ==
                                                          UserTypes.admin)
                                                    if (seat!.speaker != userId)
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(5.0),
                                                        child: InkWell(
                                                            onTap: () {
                                                              print(roomCubit
                                                                  .state
                                                                  .userType);
                                                              roomCubit
                                                                  .addSpeaker(
                                                                  userId,
                                                                  seat!);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: const [
                                                                  Text(
                                                                    'Take seat',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        fontSize:
                                                                        16),
                                                                  )
                                                                ])),
                                                      ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        10.0),
                                                    child: InkWell(
                                                        onTap: () {
                                                          seat!.speaker!
                                                              .isNotEmpty
                                                              ? onSpeakerSeatTapped(
                                                              context,
                                                              roomCubit
                                                                  .state
                                                                  .userType,
                                                              seat)
                                                              : onEmptySeatTapped(
                                                              context,
                                                              roomCubit
                                                                  .state
                                                                  .userType,
                                                              seat);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(
                                                                seat!.speaker!
                                                                    .isNotEmpty
                                                                    ? speakerSeatButtonText(
                                                                    roomCubit
                                                                        .state
                                                                        .userType,
                                                                    seat)
                                                                    : emptySeatButtonText(
                                                                    roomCubit
                                                                        .state
                                                                        .userType,
                                                                    seat),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    16),
                                                              )
                                                            ])),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: seat.speaker.toString().isNotEmpty
                                          ?  CircleAvatar(
                                        maxRadius: 30,
                                        minRadius: 30,
                                        backgroundColor: PrimaryColor,
                                        child: Icon(Icons.person,
                                            color: Colors.white),
                                      )
                                          : CircleAvatar(
                                        maxRadius: 30,
                                        minRadius: 30,
                                        backgroundColor:PrimaryColor,
                                        child: Icon(
                                            seat.closed
                                                ? Icons.lock
                                                : Icons.event_seat,
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                          // SizedBox(height: MediaQuery.of(context).size.height/7,),
                          if (roomModel.messages != null)
                            SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                child: roomChat(roomModel.messages!.toList(),
                                    scrollController)),
                        ],
                      ),
                    );
                  },
                ),
              ]),
              bottomNavigationBar: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                    color: Colors.white,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (roomCubit.state.userType == UserTypes.owner ||
                              roomCubit.state.userType == UserTypes.admin)
                            RequestsButton(context),
                          if(roomModel.chatEnabled!)
                            Expanded(
                                child: roomTextField(context, messageController)),
                          if (WidgetsBinding.instance.window.viewInsets.bottom >
                              0.0)
                            IconButton(
                                onPressed: () {
                                  messagesCubit.sendMessage(
                                      context,
                                      messageController.text.trim(),
                                      widget.roomModel.roomId.toString(),
                                      widget.roomModel.roomId.toString(),
                                      true,
                                      true);
                                  messageController.clear();
                                },
                                icon: const Icon(Icons.send)),
                          if (WidgetsBinding.instance.window.viewInsets.bottom ==
                              0.0)
                            IconButton(
                                onPressed: () {},
                                icon:  const Icon(Icons.card_giftcard,color:PrimaryColor,))
                        ],
                      ),
                    )),
              ),
            );
          }else{
            return Scaffold();
          }
        },));
  }
}
