import 'package:firebase_auth/firebase_auth.dart';
import 'package:encription_caht/firebase/fb_auth_controller.dart';
import 'package:encription_caht/models/process_response.dart';

mixin FbHelper {

  ProcessResponse get failureResponse =>
      ProcessResponse("Something went wrong", false);

  ProcessResponse getAuthExceptionResponse(FirebaseAuthException e) {
    return ProcessResponse(e.message ?? "", false);
  }

  String get myID =>  FbAuthController().currentUser.uid;
}
