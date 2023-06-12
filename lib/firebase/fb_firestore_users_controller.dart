import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:encription_caht/firebase/fb_auth_controller.dart';
import 'package:encription_caht/firebase/fb_helper.dart';
import 'package:encription_caht/models/chat_user.dart';

class FbFireStoreUsersController with FbHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///Operations
  ///1) Read all users
  ///2) changeOnlineStatus

  static FbFireStoreUsersController? _instnace;

  FbFireStoreUsersController._();

  factory FbFireStoreUsersController() {
    return _instnace ??= FbFireStoreUsersController._();
  }

  Future<bool> saveUser(ChatUser chatUser) async {
    return _firestore
        .collection("Users")
        .doc(chatUser.id)
        .set(chatUser.toJson())
        // .add(chatUser.toJson())
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> updateMyOnlineStatus(bool onlineStatus) async {
    return _firestore
        .collection("Users")
        .doc(myID)
        .update({"online": onlineStatus})
        .then((value) => true)
        .catchError((error) => false);
  }

  Stream<QuerySnapshot<ChatUser>> readUsers() async* {
    yield* _firestore
        .collection("Users")
        .where("id", isNotEqualTo: FbAuthController().currentUser.uid)
        .withConverter<ChatUser>(
            fromFirestore: (snapshot, options) =>
                ChatUser.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson())
        .snapshots();
  }
}
