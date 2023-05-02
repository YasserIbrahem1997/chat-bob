part of 'messages_cubit.dart';

@immutable
abstract class MessagesState {
  ChatModel get currentChat=>ChatModel();
  UserModel get currentReceiver=>UserModel();
}

class MessagesInitial extends MessagesState {}
class ChatFound extends MessagesState {
  ChatModel chatModel;
  UserModel receiver;
  ChatFound(this.chatModel,this.receiver);

  @override
  // TODO: implement currentChatId
  ChatModel get currentChat => chatModel;

  @override
  // TODO: implement currentReceiver
  UserModel get currentReceiver => receiver;
}

class ChatImagePickedSuccess extends MessagesState{}
class ChatImageMessageError extends MessagesState{
  final String message;
  ChatImageMessageError(this.message);
}

class UploadImageToFireBaseLoding extends MessagesState{}
class UploadImageToFireBaseSacsec extends MessagesState{}
class UploadImageToFireBaseError extends MessagesState{}

