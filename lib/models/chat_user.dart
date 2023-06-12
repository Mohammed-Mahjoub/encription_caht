class ChatUser {
  late String id;
  late String name;
  late String email;
  late bool online;
  late String image;
  late String fcmToken;

  late String password;

  ChatUser();

  ChatUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    online = json['online'] ?? false;
    image = json['image'] ?? '';
    fcmToken = json['fcm_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    // data['online'] = online;
    // data['image'] = image;
    data['fcm_token'] = fcmToken;
    return data;
  }
}
