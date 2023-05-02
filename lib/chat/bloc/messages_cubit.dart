import 'dart:io';

import 'package:bob_app/chat/data/chatModel.dart';
import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(MessagesInitial());
  final firebase = FirebaseFirestore.instance;

  MessagesCubit get(context) => BlocProvider.of(context);

  createChat(context,UserModel receiver) {
    String userId=CacheHelper.getData(key: 'uid');
    String id = Uuid().v4();
    firebase.collection('chats').doc(id.toString()).set({
      'members': [receiver.userId,userId],
      'messages': [],
      'id': id,
      'group': false,
      'videoRoom': [],
      'voiceRoom': [],
    }).then((value) {
      emit(ChatFound(ChatModel(id: id),receiver));
    });
  }

  checkChat(context,UserModel receiver, bool group) async {
    try {
      emit(MessagesInitial());
      String userId = CacheHelper.getData(key: 'uid');


      QuerySnapshot querySnapshot = await firebase
          .collection('chats')
          .where('members', arrayContains: userId)
          .get();

      List<DocumentSnapshot> docsList = querySnapshot.docs.toList();
      List<DocumentSnapshot> tempDocs = docsList
          .where((element) => element['members'].contains(receiver.userId))
          .toList();
      if (tempDocs.isNotEmpty) {
        ChatModel chat = ChatModel.fromJson(tempDocs.first.data() as Map<String,dynamic>);
        emit(ChatFound(chat,receiver));
      } else {
        createChat(context, receiver);
      }
      print(state.currentChat.id);
    } catch (e) {
      print(e.toString());
    }
  }

  sendMessage(context, String message, String receiver, chatId, bool isImage,bool isRoom) {
    String userId = CacheHelper.getData(key: 'uid');
    firebase.collection(isRoom?"rooms":'chats').doc(chatId).update({
      'messages': FieldValue.arrayUnion([
        {
          "message": message,
          "isImage": isImage,
          "isVideo": false,
          "isRecord":false,
          "image": isImage ? message : '',
          "video": "",
          'sender': userId,
          "receiver": receiver,
          'dateTime': Timestamp.now(),
        }
      ])
    });
  }

  final ImagePicker picker = ImagePicker();
  String imagePath = '';
  File? imageFile;

  Future<void> getChatImage({context, receiverId, chatId}) async {
    try {
      String userID = CacheHelper.getData(key: 'uid');
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        imagePath = image.path;
        imageFile = File(image.path);
        uploadProfileImage(receiverId, chatId, context);
      } else {
        print("No Image Selected");
      }
    } catch (e) {
      emit(ChatImageMessageError(e.toString()));
    }
  }

// this fut with uplode image in fairbase

  void uploadProfileImage(receiverId, chatId, context) async {
    try {
      String imageId = Uuid().v4();
      emit(UploadImageToFireBaseLoding());
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('chat')
          .child(imageId)
          .putFile(imageFile!)
          .then((value) {
        print('qqqqqqqqq');
        value.ref.getDownloadURL().then((value) {
          sendMessage(context, value, receiverId, chatId, true,false);
        }).catchError((e) {
          emit(ChatImageMessageError(e.toString()));
          print(e.toString() + 'zzzzzzzmmmmmmmmm');
        });
      });
    } catch (e) {
      emit(ChatImageMessageError(e.toString()));
      print(e.toString() + 'zzzzzzzz');
    }
  }

  void uploadRecord(receiverId, chatId, context, recordFile) async {
    try {
      String recordId = const Uuid().v4();
      emit(UploadImageToFireBaseLoding());
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('record/')
          .child(recordId)
          .putFile(recordFile!)
          .then((value) {
        print('qqqqqqqqq');
        value.ref.getDownloadURL().then((value) {
          sendMessage(context, value, receiverId, chatId, false,false);
        }).catchError((e) {
          emit(ChatImageMessageError(e.toString()));
          print(e.toString() + 'zzzzzzzmmmmmmmmm');
        });
      });
    } catch (e) {
      emit(ChatImageMessageError(e.toString()));
      print(e.toString() + 'zzzzzzzz');
    }
  }
}