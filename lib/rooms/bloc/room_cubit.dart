import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:bob_app/zegoManager/zegoVoiceCubit/zego_voice_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import '../service/roomUserType.dart';
part 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit() : super(RoomInitial());
  var firestoreRooms=FirebaseFirestore.instance.collection('rooms');
  final ImagePicker picker = ImagePicker();
  String imagePath = '';
  File? imageFile;


  createRoom(context,name,int seatNumber){
    String userId=CacheHelper.getData(key: 'uid');

    emit(RoomLoading());
    try{
      String admin=CacheHelper.getData(key: 'uid');
      var roomId=Uuid().v4();
      firestoreRooms.doc(roomId).set({
        'roomId':roomId,
        'name':name,
        'seatNumber':seatNumber,
        'owner':admin,
        'admins':FieldValue.arrayUnion([admin]),
        "listeners":FieldValue.arrayUnion([admin]),
        'seats':[],
        'requests':[],
        'messages':[],
        'members':[],
        'image':'',
        "backGround":'',
        "chatEnabled":true,
        "description":'',
        "announcement":'',
        'kicked':[],
      }).then((value) {
        for(int i=0;i<seatNumber;i++){
          firestoreRooms.doc(roomId).update({
            "seats":FieldValue.arrayUnion([
              {
                "seat":i,
                'speaker':'',
                'closed':false,
              }
            ])
          });
        }
      });
      emit(RoomCreated(roomId));
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  enterRoom(context,RoomModel roomModel)async{
    try{
      UserTypes userTypes;
      String userId=CacheHelper.getData(key: 'uid');
      emit(RoomLoading());
      if(roomModel.kicked!.contains(userId)){
        emit(RoomError('Sorry! you cannot join room'));
      }else{
   await   firestoreRooms.doc(roomModel.roomId).update({
        'listeners':FieldValue.arrayUnion([userId])
      });
      userTypes=  setUserRoles(roomModel);

      emit(RoomEntered(roomModel,userTypes));
      }
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  joinRoom(RoomModel roomModel){
    String userId=CacheHelper.getData(key: 'uid');

    try{
      firestoreRooms.doc(roomModel.roomId).update({'members':FieldValue.arrayUnion([userId])});
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  exitRoom(RoomModel roomModel){
    String userId=CacheHelper.getData(key: 'uid');

    try{
      firestoreRooms.doc(roomModel.roomId).update({'members':FieldValue.arrayRemove([userId])});
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }


  UserTypes setUserRoles(RoomModel roomModel){
    String userId=CacheHelper.getData(key: 'uid');

    UserTypes userTypes;

    if(roomModel.owner.toString()==userId){
      userTypes=UserTypes.owner;
    }else if(roomModel.admins!.contains(userId)){
      userTypes=UserTypes.admin;
    }else{
      userTypes=UserTypes.listener;
    }
    return userTypes;
  }

  makeAdmin(String userId,String roomId){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        "admins":FieldValue.arrayUnion([userId])
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  removeAdmin(String userId,String roomId){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        "admins":FieldValue.arrayRemove([userId])
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  kickFromRoom(String userId,String roomId){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        "kicked":FieldValue.arrayUnion([userId]),
        'members':FieldValue.arrayRemove([userId])
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  checkSeats(context,roomSeats,List members,RoomModel roomModel){
    String userId=CacheHelper.getData(key: 'uid');

    List<Seat> seats=roomSeats;
    List speakers=state.speakers;
    List<String>seatIds=[];
    seats.forEach((element) {if(element.speaker.toString().isNotEmpty){seatIds.add(element.speaker.toString());}});

    try{
      if(speakers.isEmpty){
        for(Seat seat in seats){
          if(seat.speaker.toString().isNotEmpty){
            speakers.add(seat.speaker);
            if(speakers.contains(userId)){
              emit(RoomUpdated(seats, speakers,state.userType==UserTypes.admin? state.userType : UserTypes.speaker,true,state.currentRoom,members));
            }else{
              UserTypes userTypes=setUserRoles(state.currentRoom);
              emit(RoomUpdated(seats, speakers,userTypes,false,state.currentRoom,members));

            }
          }
        }

      }else{
        var condition1 = seatIds.toSet().difference(speakers.toSet()).isEmpty;
        var condition2 = seatIds.length == speakers.length;
        var isEqual = condition1 && condition2;

        if(isEqual){

          if(roomModel.admins!.contains(userId)&&state.userType!=UserTypes.admin){
            emit(RoomUpdated(state.roomSeats, state.speakers, UserTypes.admin, state.speakingNow, state.currentRoom, members));
          }else if(!roomModel.admins!.contains(userId)&&state.userType==UserTypes.admin){
            emit(RoomUpdated(state.roomSeats, state.speakers, UserTypes.listener, state.speakingNow, state.currentRoom, members));
          }else if(roomModel.kicked!.contains(userId)){
            emit(Kickedout());
          }




        }else{
          print(false);
          speakers.clear();

          for(Seat seat in seats) {
            if(seat.speaker.toString().isNotEmpty){
              speakers.add(seat.speaker);
            }
          }

          if(speakers.contains(userId)){
            print("speaking");
            emit(RoomUpdated(seats, speakers, UserTypes.speaker,true,state.currentRoom,members));
          }else{
            UserTypes userTypes=setUserRoles(state.currentRoom);

            print('stop');
            emit(RoomUpdated(seats, speakers,userTypes,false,state.currentRoom,members));
          }

        }
      }
    }catch(e){
      print('zzzzzzzzzzzzzzz');
      print(e.toString());

    }

  }

  runStreams(context){
    String userId=CacheHelper.getData(key: 'uid');

    ZegoVoiceCubit zegoVoiceCubit=BlocProvider.of<ZegoVoiceCubit>(context,listen: false);

    List speakersStreams=state.speakers;
    for(var stream in speakersStreams){
      if(stream!=userId){
        zegoVoiceCubit.startPlayingStream(stream.toString());
      }
    }
    if(speakersStreams.contains(userId)){
      if(state.speakingNow){
        print('started');
        zegoVoiceCubit.startPublishingStream();
      }else{
        print('stopped');
        zegoVoiceCubit.stopPublishingStream();
      }
    }else{
      print('stopped');
      zegoVoiceCubit.stopPublishingStream();
    }

  }

  leaveRoom(context,userId,roomId){
    try{
      emit(RoomLoading());
      firestoreRooms.doc(roomId).update({
        'listeners':FieldValue.arrayRemove([userId])
      });
      emit(RoomLeft());
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  requestSeat(int seatNum){
    try{
      String requestId=Uuid().v4();
      String userId=CacheHelper.getData(key: 'uid');
      firestoreRooms.doc(state.currentRoom.roomId).update({
        'requests':FieldValue.arrayUnion([{
          'userId':userId,
          'seat':seatNum,
          'requestId':requestId
        }])
      });

    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  acceptRequest(Requests request){
    try{

      deleteRequest(request);
      addSpeaker(request.userId.toString(), Seat(seat: request.seat,closed:false,speaker: ''));
    }catch(e){
      print(e.toString());
      emit(RoomError(e.toString()));
    }
  }

  deleteRequest(Requests request,){
    try{
      firestoreRooms.doc(state.currentRoom.roomId).update({
        'requests':FieldValue.arrayRemove([request.toJson()])
      }).onError((error, stackTrace) {
        emit(RoomError(error.toString()));
      });
    }catch(e){
      print(e.toString());
      emit(RoomError(e.toString()));
    }
  }

  addSpeaker(String memberId,Seat seat){
    try{
      firestoreRooms.doc(state.currentRoom.roomId).update({
        'seats':FieldValue.arrayRemove([seat.toJson()])
      }).then((value) {
        firestoreRooms.doc(state.currentRoom.roomId).update({
          'seats':FieldValue.arrayUnion([{
            'closed':seat.closed,
            'seat':seat.seat,
            'speaker':memberId
          }])
        });
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  removeSpeaker(Seat seat){
    try{
      firestoreRooms.doc(state.currentRoom.roomId).update({
        'seats':FieldValue.arrayRemove([seat.toJson()])
      }).then((value) {
        firestoreRooms.doc(state.currentRoom.roomId).update({
          'seats':FieldValue.arrayUnion([{
            'closed':seat.closed,
            'seat':seat.seat,
            'speaker':''
          }])
        });
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }

  toggleSeat(Seat seat){
    try{
      firestoreRooms.doc(state.currentRoom.roomId).update({
        'seats':FieldValue.arrayRemove([seat.toJson()])
      }).then((value) {
        firestoreRooms.doc(state.currentRoom.roomId).update({
          'seats':FieldValue.arrayUnion([{
            'closed':!seat.closed,
            'seat':seat.seat,
            'speaker':seat.speaker
          }])
        });
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
  }


  //************Settings section

toggleChat(RoomModel room){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(room.roomId).update(
          {
            'chatEnabled':!room.chatEnabled!
          });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}

changeName(RoomModel room,String name){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(room.roomId).update(
          {
            'name':name
          });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}

sendAnnouncement(RoomModel room,announcement){
    try{
      firestoreRooms.doc(room.roomId).update({
        'announcement':announcement
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}
changeDescription(roomId,description){
    try{
      firestoreRooms.doc(roomId).update({
        'description':description
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}

  Future<void> pickRoomImage(userID,bool backGround,RoomModel room) async {
    String userId=CacheHelper.getData(key: 'uid');

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        imagePath = image.path;
        imageFile = File(image.path);
        String imageName = '$userID.jpg';
        uploadImage(imageName, userId, backGround,room);
      }
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }
  void uploadImage(imageName, userId,bool backGround,RoomModel room) async {
    try {
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/')
          .child(imageName)
          .putFile(imageFile!)
          .then((value) {
        value.ref.getDownloadURL().then((value) {
          backGround?changeRoomBackGround(room,value):changeRoomImage(room,value);
      });
    });
    } catch (e)
      {
        emit(RoomError(e.toString()));
      }

  }

  changeRoomImage(RoomModel room,String image){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(room.roomId).update(
          {
            'image':image
          });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}

changeRoomBackGround(RoomModel room,String image){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(room.roomId).update(
          {
            'backGround':image
          });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}
removeRoomBackGround(roomId){
    try{
      FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        "backGround":""
      });
    }catch(e){
      emit(RoomError(e.toString()));
    }
}





}