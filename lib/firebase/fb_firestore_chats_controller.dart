import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encription_caht/firebase/fb_helper.dart';
import 'package:encription_caht/models/chat.dart';

class FbFireStoreChatsController with FbHelper {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static FbFireStoreChatsController? _instance;

  FbFireStoreChatsController._();

  factory FbFireStoreChatsController() {
    return _instance ??= FbFireStoreChatsController._();
  }

  /// Operations:
  /// 1) readChats
  /// 2) manageChat(partnerPeerId)
  ///    => YES: fetch Chat
  ///    => NO : Create new chat

  Stream<QuerySnapshot<Chat>> fetchChats() async* {
    yield* _firestore
        .collection("Chats")
        .where("peers", arrayContainsAny: [myID])
        .withConverter<Chat>(
          fromFirestore: (snapshot, options) => Chat.fromJson(snapshot.data()!),
          toFirestore: (value, options) => value.toJson(),
        )
        .snapshots();
  }

  ///This function called only when a user-item tapped
  Future<Chat> manageChat(String partnerPeerId) async {
    Chat? chat = await _isChatExisted(partnerPeerId);
    if (chat != null) {
      print("Existed");
      return chat;
    } else {
      print("New Chat");
      return await _createChat(partnerPeerId);
    }
  }

  Future<Chat?> _isChatExisted(String partnerPeerId) async {
    print("Partner: $partnerPeerId");
    print("MyId: $myID");
    CollectionReference collectionReference = _firestore.collection('Chats');
    Query firstQuery = collectionReference.where("peers", whereIn: [
      [partnerPeerId, myID],
      [myID, partnerPeerId]
    ]);

    QuerySnapshot<Chat> data = await firstQuery
        .withConverter<Chat>(
            fromFirestore: (snapshot, options) =>
                Chat.fromJson(snapshot.data()!),
            toFirestore: (Chat chat, options) => chat.toJson())
        .get();
    if (data.docs.isNotEmpty) {
      var document = data.docs.first;
      Chat chat = document.data();
      chat.id = document.id;
      return chat;
    }
    return null;
  }

  Future<Chat> _createChat(String partnerPeerId) async {
    Chat chat = _generateNewChat(partnerPeerId);
    return _firestore
        .collection("Chats")
        .add(chat.toJson())
        .then((value) => chat..id = value.id);
  }

  Chat _generateNewChat(String partnerPeerId) {
    Chat chat = Chat();
    chat.peers = [myID, partnerPeerId];
    chat.peer1 = FirebaseFirestore.instance.collection('Users').doc(myID);
    chat.peer2 =
        FirebaseFirestore.instance.collection('Users').doc(partnerPeerId);
    chat.createdBy = myID;
    return chat;
  }

  // Future<void> sendPushMessage({required UserModel userModel}) async {
  //   String fcm = await FbFireStoreController().getAdminFcmToken();
  //   try {
  //     var response = await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization':
  //             'key=AAAAZ-Xy57s:APA91bFRri2QVsUlbkV458FKYaq-UPOQCGz1SuKUxYSyLk4x-7JTL8TQuRmvAwL3MuNtlRNAuHfP4WqRLIcnorzvDMEdME_5VydMb87j0AooVfUe2ToWglO8tBWOgvsUnH3OHJ6F_GEJ'
  //       },
  //       body: jsonEncode({
  //         'registration_ids': [fcm],
  //         'data': {
  //           'via': 'FlutterFire Cloud Messaging!!!',
  //           'count': '1',
  //         },
  //         'notification': {
  //           'title': 'اشعار جديد',
  //           'body':
  //               'تم تسليم ${userModel.userName}  الوجبة الخاصة في هذا اليوم ',
  //         },
  //       }),
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
