part of 'room_cubit.dart';

@immutable
abstract class RoomState {
  RoomModel get currentRoom=>RoomModel();
  UserTypes get userType=>UserTypes.listener;
  List<Seat>get roomSeats=>[];
  List  get speakers=>[];
  bool get speakingNow=>false;
  List get roomMembers=>[];
}

class RoomInitial extends RoomState {}
class RoomLoading extends RoomState {}

class RoomEntered extends RoomState {
  final RoomModel joinedRoom;
  final UserTypes userTypes;
  RoomEntered(this.joinedRoom,this.userTypes);


  @override
  UserTypes get userType => userTypes;

  @override
  RoomModel get currentRoom=>joinedRoom;

  @override
  get roomSeats=>joinedRoom.seats!.toList();

  @override
  // TODO: implement roomMembers
  List get roomMembers => joinedRoom.listeners!.toList();

}

class RoomUpdated extends RoomState{
  final List<Seat>seats;
  final List roomSpeakers;
  final UserTypes userTypes;
  final bool speaking;
  final RoomModel room;
  final List members;
  RoomUpdated(this.seats,this.roomSpeakers,this.userTypes,this.speaking,this.room,this.members);

  @override
  get speakers=>roomSpeakers;

  @override
  get roomSeats=>seats;

  @override
  UserTypes get userType => userTypes;

  @override
  get speakingNow=>speaking;

  @override
  get currentRoom=>room;

  @override
  // TODO: implement roomMembers
  List get roomMembers => members;

}

class RoomLeft extends RoomState {
  @override
  String get roomId=>'';
}
class RoomCreated extends RoomState {
  final String createdRoomId;
  RoomCreated(this.createdRoomId);

  @override
  // TODO: implement roomId
  String get roomId => createdRoomId;
}
class Kickedout extends RoomState{}
class RoomError extends RoomState {
  final  String message;
  RoomError(this.message);
}