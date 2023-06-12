import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:encription_caht/firebase/fb_firestore_users_controller.dart';
import 'package:encription_caht/firebase/fb_helper.dart';
import 'package:encription_caht/models/chat_user.dart';
import 'package:encription_caht/models/process_response.dart';

class FbAuthController with FbHelper {
  static FbAuthController? _instance;

  FbAuthController._();

  factory FbAuthController() {
    return _instance ??= FbAuthController._();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ProcessResponse> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        // bool isEmailVerified = userCredential.user!.emailVerified;
        bool isEmailVerified = true;
        String message = isEmailVerified
            ? "Logged in successfully"
            : "Email is not verified!";
        if (!isEmailVerified) await signOut();
        return ProcessResponse(message, isEmailVerified);
      }
    } on FirebaseAuthException catch (e) {
      return getAuthExceptionResponse(e);
    }
    return failureResponse;
  }

  Future<ProcessResponse> createAccount(ChatUser chatUser) async {
    var token = await FirebaseMessaging.instance.getToken();
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: chatUser.email, password: chatUser.password);
      if (userCredential.user != null) {
        // await userCredential.user!.sendEmailVerification();
        await userCredential.user!.updateDisplayName(chatUser.name);
        chatUser.id = userCredential.user!.uid;
        chatUser.fcmToken = token ?? "";
        await FbFireStoreUsersController().saveUser(chatUser);
        await signOut();
        return ProcessResponse("Verification email sent, verify and login");
      }
    } on FirebaseAuthException catch (e) {
      return getAuthExceptionResponse(e);
    } catch (e) {
      print(e);
    }
    return failureResponse;
  }

  Future<ProcessResponse> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ProcessResponse("Reset link sent successfully");
    } on FirebaseAuthException catch (e) {
      return getAuthExceptionResponse(e);
    } catch (e) {
      return failureResponse;
    }
  }

  Future<void> signOut() => _auth.signOut();

  bool get loggedIn => _auth.currentUser != null;

  User get currentUser => _auth.currentUser!;
}
