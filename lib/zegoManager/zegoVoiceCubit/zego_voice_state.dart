part of 'zego_voice_cubit.dart';

@immutable
abstract class ZegoVoiceState {

  Widget?  get previewViewWidget=>SizedBox();
  Widget? get  playViewWidget=>SizedBox();
}

class ZegoVoiceInitial extends ZegoVoiceState {}
class PreviewSet extends ZegoVoiceState {

  final Widget? previewView;
  final Widget? playView;
  PreviewSet(this.playView,this.previewView);
  @override
  Widget get previewViewWidget => previewView!;

  @override
    // TODO: implement playViewWidget
  Widget get playViewWidget => playView!;


}
