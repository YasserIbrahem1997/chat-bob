import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  List? videoRoom;
  List? members;
  List<MessageModel>? messages;
  String? id;
  List? voiceRoom;
  bool? group;

  ChatModel(
      {this.videoRoom,
        this.members,
        this.messages,
        this.id,
        this.voiceRoom,
        this.group});

  ChatModel.fromJson(Map<String, dynamic> json) {
      videoRoom =json['videoRoom'];
    members = json['members'].cast<String>();
      if(json['messages']!=null){
        messages=<MessageModel>[];
        json['messages'].forEach((v){
          messages!.add(MessageModel.fromJson(v));
        });
      }
    id = json['id'];
      voiceRoom = json['voiceRoom'];
    group = json['group'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
      data['videoRoom'] = this.videoRoom;
    data['members'] = this.members;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
      data['voiceRoom'] = this.voiceRoom;
    data['group'] = this.group;
    return data;
  }
}

class MessageModel {
  String? message;
  bool? isImage;
  bool? isVideo;
  bool? isRecord;
  String? image;
  String? record;
  String? video;
  String? sender;
  String? receiver;
  Timestamp? dateTime;

  MessageModel(
      {this.message,
        this.isImage,
        this.isVideo,
        this.isRecord,
        this.image,
        this.record,
        this.video,
        this.sender,
        this.receiver,
        this.dateTime});

  MessageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    isImage = json['isImage'];
    isVideo = json['isVideo'];
    isRecord = json['isRecord'];
    image = json['image'];
    record = json['record'];
    video = json['video'];
    sender = json['sender'];
    receiver = json['receiver'];
    dateTime = json['dateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['isImage'] = this.isImage;
    data['isVideo'] = this.isVideo;
    data['isRecord'] = this.isRecord;
    data['image'] = this.image;
    data['record'] = this.record;
    data['video'] = this.video;
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    data['dateTime'] = this.dateTime;
    return data;
  }
}
