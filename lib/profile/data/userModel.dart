class UserModel {
  String? image;
  String? phone;
  String? name;
  String? userId;
  String? email;

  UserModel({this.image, this.phone, this.name, this.userId, this.email});

  UserModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    phone = json['phone'];
    name = json['name'];
    userId = json['userId'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['phone'] = this.phone;
    data['name'] = this.name;
    data['userId'] = this.userId;
    data['email'] = this.email;
    return data;
  }
}
