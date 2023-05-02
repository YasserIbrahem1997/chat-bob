part of 'voice_call_cubit.dart';

@immutable
abstract class VoiceCallState {}

class VoiceCallInitial extends VoiceCallState {}
class VoiceLoading extends VoiceCallState {}
class VoiceJoined extends VoiceCallState {}
class VoiceLeft extends VoiceCallState {}
class VoiceError extends VoiceCallState {
  String message;
  VoiceError(this.message);
}
