class PackageModel {
  String? coins;
  String? id;
  String? cash;

  PackageModel({this.coins, this.id, this.cash});

  PackageModel.fromJson(Map<String, dynamic> json) {
    coins = json['coins'];
    id = json['id'];
    cash = json['cash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coins'] = this.coins;
    data['id'] = this.id;
    data['cash'] = this.cash;
    return data;
  }
}
