import '../../chat/data/chatModel.dart';

class RoomModel {
  List? listeners;
  String? name;
  String? owner;
  List<Requests>? requests;
  List<Seat>? seats;
  String? roomId;
  List? admins;
  int? seatNumber;
  String? requestId;
  List<MessageModel>? messages;
  List? kicked;
  List? members;
  String? image;
  String? backGround;
  String? announcement;
  String? description;
  bool? chatEnabled;

  RoomModel(
      {this.listeners,
      this.name,
      this.chatEnabled,
      this.backGround,
      this.image,
      this.requests,
      this.seats,
      this.roomId,
      this.admins,
      this.owner,
      this.seatNumber,
      this.requestId,
      this.messages,
      this.description,
      this.kicked,
      this.members});

  RoomModel.fromJson(Map<String, dynamic> json) {
    listeners = json['listeners'] == null ? [] : json['listeners'];
    members = json['members'] == null ? [] : json['members'];
    name = json['name'];
    image = json['image'];
    backGround = json['backGround'];
    announcement = json['announcement'];
    description = json['description'];
    owner = json['owner'];
    chatEnabled = json['chatEnabled'];
    kicked = json['kicked'];
    if (json['messages'] != null) {
      messages = <MessageModel>[];
      json['messages'].forEach((v) {
        messages!.add(MessageModel.fromJson(v));
      });
    }
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(new Requests.fromJson(v));
      });
    }
    if (json['seats'] != null) {
      seats = <Seat>[];
      json['seats'].forEach((v) {
        seats!.add(new Seat.fromJson(v));
      });
    }
    roomId = json['roomId'];
    admins = json['admins'].cast<String>();
    seatNumber = json['seatNumber'];
    requestId = json['requestId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['listeners'] = this.listeners;
    data['name'] = this.name;
    data['chatEnabled'] = this.chatEnabled;
    data['owner'] = this.owner;
    if (this.requests != null) {
      data['requests'] = this.requests!.map((v) => v.toJson()).toList();
    }
    if (this.seats != null) {
      data['seats'] = this.seats!.map((v) => v.toJson()).toList();
    }
    data['roomId'] = this.roomId;
    data['announcement'] = this.announcement;
    data['description'] = this.description;
    data['admins'] = this.admins;
    data['backGround'] = this.backGround;
    data['seatNumber'] = this.seatNumber;
    data['requestId'] = this.requestId;
    data['image'] = this.image;
    data['messages'] = this.messages;
    return data;
  }
}

class Requests {
  int? seat;
  String? userId;
  String? requestId;

  Requests({this.seat, this.userId});

  Requests.fromJson(Map<String, dynamic> json) {
    seat = json['seat'];
    userId = json['userId'];
    requestId = json['requestId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seat'] = this.seat;
    data['userId'] = this.userId;
    data['requestId'] = this.requestId;
    return data;
  }
}

class Seat {
  int? seat;
  String? speaker;
  bool closed = false;

  Seat({this.seat, this.speaker, this.closed = false});

  Seat.fromJson(Map<String, dynamic> json) {
    seat = json['seat'];
    speaker = json['speaker'];
    closed = json['closed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seat'] = this.seat;
    data['speaker'] = this.speaker;
    data['closed'] = this.closed;
    return data;
  }
}
