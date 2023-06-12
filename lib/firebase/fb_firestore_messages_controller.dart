import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encription_caht/firebase/fb_helper.dart';
import 'package:encription_caht/models/chat.dart';
import 'package:encription_caht/models/chat_message.dart';

class FbFireStoreMessagesController with FbHelper {
  /**
   * Operations
   * 1) fetchChatMessages(chatId) : Stream
   * 2) sendMessage(chatMessage) : Future
   * 3) deleteMessage(for: ?, messageId: int) : Future
   */

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<ChatMessage>> fetchChatMessages(String chatId) async* {
    yield* _firestore
        .collection("ChatMessages")
        .where("chat_id", isEqualTo: chatId)
        // .orderBy('sent_at', descending: true)
        .withConverter<ChatMessage>(
          fromFirestore: (snapshot, options) =>
              ChatMessage.fromJson(snapshot.data()!),
          toFirestore: (value, options) => value.toJson(),
        )
        .snapshots();
  }

  Future<bool> sendMessage(ChatMessage chatMessage) async {
    return _firestore
        .collection("ChatMessages")
        .add(chatMessage.toJson())
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> deleteMessage(String messageId, bool deleteForEveryone) async {
    return _firestore
        .collection("ChatMessages")
        .doc(messageId)
        .update({
          "deleted_for_every_one": deleteForEveryone,
          "deleted_for": [myID]
        })
        .then((value) => true)
        .catchError((error) => false);
  }
}
