import 'package:encription_caht/encrypt_aes.dart';
import 'package:encription_caht/firebase/fb_auth_controller.dart';

enum MessageType {text, voice, image}
class ChatMessage {
  late String id;
  late String chatId;
  late String message;
  late String type;
  late String senderId;
  late String receiverId;
  late String sentAt;
  late bool deletedForEveryOne;
  late List<String> deletedFor;
  late bool sentByMe;

  ChatMessage();

  ChatMessage.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    message = json['message'];
    type = json['type'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    sentAt = json['sent_at'];
    deletedForEveryOne = json['deleted_for_every_one'];
    deletedFor = json['deleted_for'].cast<String>();
    sentByMe = FbAuthController().myID == senderId;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['message'] = message;
    data['type'] = type;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['sent_at'] = sentAt;
    data['deleted_for_every_one'] = false;
    data['deleted_for'] = [];
    return data;
  }

}
