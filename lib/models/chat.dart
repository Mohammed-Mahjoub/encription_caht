import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encription_caht/firebase/fb_auth_controller.dart';

class Chat {
  late String id;
  late DocumentReference peer1;
  late DocumentReference peer2;
  late List<dynamic> peers;
  late String createdBy;
  late String createdAt;
  late String lastMessage;

  Chat();

  Chat.fromJson(Map<String, dynamic> json) {
    // peer1 = json['peer1'];
    // peer2 = json['peer2'];
    peers = json['peers'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    lastMessage = json['last_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['peer1'] = peer1;
    data['peer2'] = peer2;
    data['peers'] = peers;
    data['created_by'] = createdBy;
    data['created_at'] = DateTime.now().millisecondsSinceEpoch.toString();
    data['last_message'] = "";
    return data;
  }

  String getId({bool me = false}) {
    String myId = FbAuthController().myID;
    return me
        ? myId
        : peers.firstWhere((element) => element != myId);
  }
}
