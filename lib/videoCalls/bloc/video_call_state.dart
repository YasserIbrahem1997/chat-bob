part of 'video_call_cubit.dart';

@immutable
abstract class VideoCallState {}

class VideoCallInitial extends VideoCallState {}
class VideoLoading extends VideoCallState {}
class VideoJoined extends VideoCallState {}
class VideoLeft extends VideoCallState {}
class VideoError extends VideoCallState {
  String message;
  VideoError(this.message);
}
class IsCamera extends VideoCallState{}
class IsCamerafront extends VideoCallState{}


