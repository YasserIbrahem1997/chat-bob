import 'package:bob_app/rooms/bloc/room_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/roomModel.dart';

enum UserTypes{
 owner,
 admin,
 speaker,
 listener
}

String emptySeatButtonText(UserTypes userType,Seat seat){
  switch(userType){

    case UserTypes.owner:

        return seat.closed?'Open seat' :'Close seat';
      break;
    case UserTypes.admin:
      return seat.closed?'Open seat' :'Close seat';
      break;
    case UserTypes.listener:
        return 'Request seat';
      break;
    case UserTypes.speaker:
      return '';
      break;
  }

}
String speakerSeatButtonText(UserTypes userType,Seat seat){
  switch(userType){

    case UserTypes.owner:

        return 'Remove speaker';
      break;
    case UserTypes.admin:
      return 'Remove speaker';
      break;
    case UserTypes.listener:
        return 'Request seat';
      break;
    case UserTypes.speaker:
      return 'Leave seat';
      break;
  }

}
onEmptySeatTapped(context,UserTypes userType,Seat seat){
 RoomCubit roomCubit=BlocProvider.of<RoomCubit>(context,listen: false);
 switch(userType){
   case UserTypes.owner:
    roomCubit.toggleSeat(seat);
     break;
   case UserTypes.admin:
     roomCubit.toggleSeat(seat);
     break;
   case UserTypes.speaker:
     break;
   case UserTypes.listener:
     roomCubit.requestSeat(seat.seat!.toInt());
     break;
 }
}

onSpeakerSeatTapped(context,UserTypes userType,Seat seat){
 RoomCubit roomCubit=BlocProvider.of<RoomCubit>(context,listen: false);
 switch(userType){
   case UserTypes.owner:
    roomCubit.removeSpeaker(seat);
     break;
   case UserTypes.admin:
     roomCubit.removeSpeaker(seat);
     break;
   case UserTypes.speaker:
    roomCubit.removeSpeaker(seat);
     break;
   case UserTypes.listener:
     roomCubit.requestSeat(seat.seat!.toInt());
     break;
 }
}
