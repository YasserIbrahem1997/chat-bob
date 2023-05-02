import 'package:bob_app/rooms/bloc/room_cubit.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpeakerRequests extends StatelessWidget {


  const SpeakerRequests({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RoomCubit roomCubit = BlocProvider.of<RoomCubit>(context, listen: false);
    return Scaffold(backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomCubit.state.currentRoom.roomId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            RoomModel room = RoomModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);
            return room.requests!.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: room.requests!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              Requests request = room.requests![index];
                              return Card(
                                child: ListTile(
                                  title: Text(request.userId.toString()),
                                  subtitle: Text('seat no: ${request.seat}'),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              roomCubit.deleteRequest(
                                                  request);
                                            },
                                            icon: const Icon(Icons.close)),
                                        IconButton(
                                            onPressed: () {
                                              roomCubit.acceptRequest(request);
                                            },
                                            icon: const Icon(Icons.check))
                                      ]),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text('There is no requests yet',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal)),
                  );
          } else {
            return const Center(
              child: Text('There is no requests yet',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.normal)),
            );
          }
        },
      ),
    );
  }
}
